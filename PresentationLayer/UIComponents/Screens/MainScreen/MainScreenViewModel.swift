//
//  ContentViewModel.swift
//  PresentationLayer
//
//  Created by Hristos Condrea on 17/5/22.
//

import Combine
import DomainLayer
import Foundation
import Network
import SwiftUI
import Toolkit
import WidgetKit

@MainActor
class MainScreenViewModel: ObservableObject {

    static let shared = MainScreenViewModel()

    @Published private(set) var theme: Theme = .system {
        willSet {
            updateThemeOption(newValue)
        }

        didSet {
            WXMAnalytics.shared.setUserProperty(key: .theme, value: theme.analyticsValue)
        }
	}
	/// The active theme of the device. The value will be only light or dark.
	/// eg if the user's choice is `system` and the device's theme is dark, the returned value will be dark
	var deviceActiveTheme: Theme? {
		getCurrentActiveTheme()
	}

    /// The interval to check if should show or hide wallet warning
    private let showWarningWalletInterval: TimeInterval = 24.0 * TimeInterval.hour // 1 day
    @Published private(set) var showWalletWarning: Bool = false

    let deepLinkHandler = DeepLinkHandler(useCase: SwinjectHelper.shared.getContainerForSwinject().resolve(NetworkUseCase.self)!,
										  explorerUseCase: SwinjectHelper.shared.getContainerForSwinject().resolve(ExplorerUseCase.self)!)

    private let mainUseCase: MainUseCase
	private let meUseCase: MeUseCase
    private let settingsUseCase: SettingsUseCase
	private let photosUseCase: PhotoGalleryUseCase
    private var cancellableSet: Set<AnyCancellable> = []
    let networkMonitor: NWPathMonitor
    @Published var isUserLoggedIn: Bool = false
    @Published var isInternetAvailable: Bool = false
    @Published var selectedTab: TabSelectionEnum = .homeTab
    @Published var showAnalyticsPrompt: Bool = false
	@Published var userInfo: NetworkUserInfoResponse? {
		didSet {
			updateIsWalletMissing()
		}
	}
	@Published var isWalletMissing: Bool = false
    @Published var showAppUpdatePrompt: Bool = false
	@Published var showHttpMonitor: Bool = false

    let swinjectHelper: SwinjectInterface

    private init() {
        self.swinjectHelper = SwinjectHelper.shared
        mainUseCase = swinjectHelper.getContainerForSwinject().resolve(MainUseCase.self)!
		meUseCase = swinjectHelper.getContainerForSwinject().resolve(MeUseCase.self)!
		photosUseCase = swinjectHelper.getContainerForSwinject().resolve(PhotoGalleryUseCase.self)!

        networkMonitor = NWPathMonitor()
        settingsUseCase = swinjectHelper.getContainerForSwinject().resolve(SettingsUseCase.self)!

        checkIfUserIsLoggedIn()
        settingsUseCase.initializeAnalyticsTracking()
		purgeSavedPhotos()

		NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { _ in
			WidgetCenter.shared.reloadAllTimelines()
		}

		meUseCase.userInfoPublisher.sink { [weak self] response in
			self?.userInfo = response
		}.store(in: &cancellableSet)

		mainUseCase.userLoggedInStateNotificationPublisher.sink { [weak self] _ in
			self?.checkIfUserIsLoggedIn()
		}.store(in: &cancellableSet)

		// Set the cache size in order to handle image download requests
		URLCache.shared.memoryCapacity = 10_000_000 // ~10 MB memory space
		URLCache.shared.diskCapacity = 500_000_000 // ~500 MB disk cache space
        
		RemoteConfigManager.shared.$iosAppLatestVersion.sink { [weak self] latestVersion in
			guard let latestVersion else {
				return
			}
			let minimumVersion = RemoteConfigManager.shared.iosAppMinimumVersion
			self?.showAppUpdatePrompt = self?.mainUseCase.shouldShowUpdatePrompt(for: latestVersion, minimumVersion: minimumVersion) ?? false
		}.store(in: &cancellableSet)

		RemoteConfigManager.shared.$iosAppMinimumVersion.sink { [weak self] minVersion in
			guard let minVersion,
			let latestVersion = RemoteConfigManager.shared.iosAppLatestVersion else {
				return
			}
			
			self?.showAppUpdatePrompt = self?.mainUseCase.shouldShowUpdatePrompt(for: latestVersion, minimumVersion: minVersion) ?? false
		}.store(in: &cancellableSet)

		requestNotificationAuthorizationIfNeeded()

		NotificationCenter.default.addObserver(forName: .deviceDidShake,
											   object: nil,
											   queue: .main) { [weak self] _ in
			MainActor.assumeIsolated {
				self?.showHttpMonitor = true
			}
		}
    }

    @Published var showFirmwareUpdate = false
    var deviceToUpdate: DeviceDetails?
    func showFirmwareUpdate(device: DeviceDetails) {
        showFirmwareUpdate = true
        deviceToUpdate = device
    }
    
    func initializeConfigurations() {
        theme = getThemeOption()
        updateShowWalletWarning()
        startMonitoring()
        checkIfShouldShowAnalyticsPrompt(settingsUseCase: settingsUseCase)
        cleanupAnalyticsUserIdIfNeeded()
    }

	private func requestNotificationAuthorizationIfNeeded() {
		Task { @MainActor in
			try await FirebaseManager.shared.requestNotificationAuthorization()
		}
	}

    private func checkIfUserIsLoggedIn() {
        let container = swinjectHelper.getContainerForSwinject()
        let authUseCase = container.resolve(AuthUseCase.self)!
        isUserLoggedIn = authUseCase.isUserLoggedIn()
		if isUserLoggedIn {
			selectedTab = .homeTab
		}
    }

    private func startMonitoring() {
        networkMonitor.pathUpdateHandler = { path in
			DispatchQueue.main.async {
				if path.status == .satisfied {
					self.isInternetAvailable = true
				} else {
					self.isInternetAvailable = false
				}
			}
        }
        networkMonitor.start(queue: DispatchQueue.main)
    }

    // MARK: Temperature userDefaults

    private func getTemperatureMetricEnum() -> TemperatureUnitsEnum {
        guard let temperatureUnits = mainUseCase.readOrCreateWeatherMetric(key: UserDefaults.WeatherUnitKey.temperature.rawValue) as? TemperatureUnitsEnum else {
            return .celsius
        }
        return temperatureUnits
    }

    // MARK: Percipitation userDefaults

    private func getPrecipitationMetricEnum() -> PrecipitationUnitsEnum {
        guard let precipitationUnits = mainUseCase.readOrCreateWeatherMetric(key: UserDefaults.WeatherUnitKey.precipitation.rawValue) as? PrecipitationUnitsEnum else {
            return .millimeters
        }
        return precipitationUnits
    }

    // MARK: Wind Speed userDefaults

    private func getWindSpeedMetricEnum() -> WindSpeedUnitsEnum {
        guard let windSpeedUnits = mainUseCase.readOrCreateWeatherMetric(key: UserDefaults.WeatherUnitKey.windSpeed.rawValue) as? WindSpeedUnitsEnum else {
            return .kilometersPerHour
        }
        return windSpeedUnits
    }

    // MARK: Wind Direction userDefaults

    private func getWindDirectionMetricEnum() -> WindDirectionUnitsEnum {
        guard let windDirectionUnits = mainUseCase.readOrCreateWeatherMetric(key: UserDefaults.WeatherUnitKey.windDirection.rawValue) as? WindDirectionUnitsEnum else {
            return .cardinal
        }
        return windDirectionUnits
    }

    // MARK: Pressure userDefaults

    private func getPressureMetricEnum() -> PressureUnitsEnum {
        guard let pressureUnits = mainUseCase.readOrCreateWeatherMetric(key: UserDefaults.WeatherUnitKey.pressure.rawValue) as? PressureUnitsEnum else {
            return .hectopascal
        }
        return pressureUnits
    }

    // MARK: Display Theme

    func setTheme(_ theme: Theme) {
        self.theme = theme
    }

    private func updateThemeOption(_ option: Theme) {
        mainUseCase.saveValue(key: UserDefaults.GenericKey.displayTheme.rawValue, value: option.rawValue)
        UIApplication.shared.currentKeyWindow?.overrideUserInterfaceStyle = option.interfaceStyle
    }

    private func getThemeOption() -> Theme {
        guard let persistedValue: String = mainUseCase.getValue(key: UserDefaults.GenericKey.displayTheme.rawValue) else {
            return .system
        }
        return Theme(rawValue: persistedValue) ?? .system
    }

	private func getCurrentActiveTheme() -> Theme? {
		let interfaceStyle = UIScreen.main.traitCollection.userInterfaceStyle
		let activeTheme = Theme(interfaceStyle: interfaceStyle)
		return activeTheme
	}

    // MARK: Wallet warning timestamp

    func hideWalletWarning() {
        mainUseCase.saveValue(key: UserDefaults.GenericKey.hideWalletTimestamp.rawValue, value: Date.now)
        updateShowWalletWarning()
    }

    private func updateShowWalletWarning() {
        guard let lastTimestamp: Date = mainUseCase.getValue(key: UserDefaults.GenericKey.hideWalletTimestamp.rawValue) else {
            showWalletWarning = true
            return
        }

        showWalletWarning = Date.now.timeIntervalSince(lastTimestamp) > showWarningWalletInterval
    }

	private func updateIsWalletMissing() {
		Task { @MainActor in
			guard let userInfo else {
				isWalletMissing = false
				return
			}
			let hasOwnedDevices = await meUseCase.hasOwnedDevices()
			isWalletMissing = hasOwnedDevices && ((userInfo.wallet?.address.isNilOrEmpty) ?? true)
		}
	}

    // MARK: Firmware update versions

    func firmwareUpdated(for deviceId: String, version: String) {
        let versionsData: Data = mainUseCase.getValue(key: UserDefaults.GenericKey.firmwareUpdateVersions.rawValue) ?? Data()
        var versions: [String: FirmwareVersion] = (try? JSONDecoder().decode([String: FirmwareVersion].self, from: versionsData)) ?? [:]
        versions[deviceId] = FirmwareVersion(installDate: Date.now, version: version)

        if let data = try? JSONEncoder().encode(versions) {
            mainUseCase.saveValue(key: UserDefaults.GenericKey.firmwareUpdateVersions.rawValue, value: data)
        }
    }

    func getInstalledFirmwareVersion(for deviceId: String) -> FirmwareVersion? {
        let versionsData: Data = mainUseCase.getValue(key: UserDefaults.GenericKey.firmwareUpdateVersions.rawValue) ?? Data()
        let versions: [String: FirmwareVersion]? = (try? JSONDecoder().decode([String: FirmwareVersion].self, from: versionsData))

        return versions?[deviceId]
    }

    // MARK: Analytics opt in/out

    private func checkIfShouldShowAnalyticsPrompt(settingsUseCase: SettingsUseCase) {
        guard isUserLoggedIn else {
            return
        }

        showAnalyticsPrompt = !settingsUseCase.isAnalyticsOptSet
    }

    private func cleanupAnalyticsUserIdIfNeeded() {
        guard isUserLoggedIn else {
            return
        }
        WXMAnalytics.shared.setUserId(nil)
    }

	// MARK: Photos
	private func purgeSavedPhotos() {
		do {
			try photosUseCase.purgeImages()
		} catch {
			print("Error purging photos: \(error)")
		}
	}

	// MARK: - App Update
}
