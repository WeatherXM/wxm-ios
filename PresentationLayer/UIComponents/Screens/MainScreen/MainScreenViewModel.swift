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

	let deepLinkHandler = DeepLinkHandler(useCase: SwinjectHelper.shared.getContainerForSwinject().resolve(NetworkUseCaseApi.self)!,
										  explorerUseCase: SwinjectHelper.shared.getContainerForSwinject().resolve(ExplorerUseCaseApi.self)!)

	private let mainUseCase: MainUseCaseApi
	private let meUseCase: MeUseCaseApi
	private let settingsUseCase: SettingsUseCaseApi
	private let photosUseCase: PhotoGalleryUseCaseApi
	private let stationNotificationsUseCase: StationNotificationsUseCaseApi
	private lazy var backgroundScheduler: BackgroundScheduler = {
		let scheduler = BackgroundScheduler { [weak self] in
			Task { @MainActor in
				self?.performBackgroundProcess()
			}
		}

		return scheduler
	}()
	private var cancellableSet: Set<AnyCancellable> = []
	let networkMonitor: NWPathMonitor
	@Published var isUserLoggedIn: Bool = false
	@Published var isInternetAvailable: Bool = false
	@Published var selectedTab: TabSelectionEnum = .homeTab
	@Published var showAnalyticsPrompt: Bool = false
	@Published var showTermsPrompt: Bool = false {
		didSet {
			print("showTermsPrompt \(showTermsPrompt)")
		}
	}
	@Published var userInfo: NetworkUserInfoResponse? {
		didSet {
			updateIsWalletMissing()
		}
	}
	@Published var isWalletMissing: Bool = false
	@Published var showAppUpdatePrompt: Bool = false
	@Published var showHttpMonitor: Bool = false

	lazy var termsAlertConfiguration: WXMAlertConfiguration = {
		getTermsAlertConfiguration()
	}()
	let swinjectHelper: SwinjectInterface

	private init() {
		self.swinjectHelper = SwinjectHelper.shared
		mainUseCase = swinjectHelper.getContainerForSwinject().resolve(MainUseCaseApi.self)!
		meUseCase = swinjectHelper.getContainerForSwinject().resolve(MeUseCaseApi.self)!
		photosUseCase = swinjectHelper.getContainerForSwinject().resolve(PhotoGalleryUseCaseApi.self)!
		stationNotificationsUseCase = swinjectHelper.getContainerForSwinject().resolve(StationNotificationsUseCaseApi.self)!

		networkMonitor = NWPathMonitor()
		settingsUseCase = swinjectHelper.getContainerForSwinject().resolve(SettingsUseCaseApi.self)!

		if !isRunningTests {
			let _ = backgroundScheduler
		}

        checkIfUserIsLoggedIn()
        settingsUseCase.initializeAnalyticsTracking()
		purgeSavedPhotos()

		NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { _ in
			WidgetCenter.shared.reloadAllTimelines()
		}

		meUseCase.userInfoPublisher.receive(on: DispatchQueue.main).sink { [weak self] response in
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
			self?.showAppUpdatePrompt = self?.mainUseCase.shouldShowUpdatePrompt(for: latestVersion, minimumVersion: minimumVersion, currentVersion: nil) ?? false
		}.store(in: &cancellableSet)

		RemoteConfigManager.shared.$iosAppMinimumVersion.sink { [weak self] minVersion in
			guard let minVersion,
				  let latestVersion = RemoteConfigManager.shared.iosAppLatestVersion else {
				return
			}

			self?.showAppUpdatePrompt = self?.mainUseCase.shouldShowUpdatePrompt(for: latestVersion, minimumVersion: minVersion, currentVersion: nil) ?? false
		}.store(in: &cancellableSet)

		requestNotificationAuthorizationIfNeeded()

		NotificationCenter.default.addObserver(forName: .deviceDidShake,
											   object: nil,
											   queue: .main) { [weak self] _ in
			MainActor.assumeIsolated {
				self?.showHttpMonitor = true
			}
		}

		observePhotoUploads()
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
		checkIfShouldShowTerms()
	}

	private func requestNotificationAuthorizationIfNeeded() {
		Task { @MainActor in
			try await FirebaseManager.shared.requestNotificationAuthorization()
		}
	}

	private func checkIfUserIsLoggedIn() {
		let container = swinjectHelper.getContainerForSwinject()
		let authUseCase = container.resolve(AuthUseCaseApi.self)!
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

	private func checkIfShouldShowAnalyticsPrompt(settingsUseCase: SettingsUseCaseApi) {
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

	private func checkIfShouldShowTerms() {
		let termsAccepted = mainUseCase.areTermsOfUseAccepted()
		guard !termsAccepted, isUserLoggedIn else {
			return
		}

		DispatchQueue.main.async {
			self.showTermsPrompt = true
		}
	}

	private func getTermsAlertConfiguration() -> WXMAlertConfiguration {
		let terms = LocalizableString.Settings.termsOfUse.localized
		let termsUrl = LocalizableString.url(terms,
											 DisplayedLinks.termsOfUse.linkURL).localized

		let privacy = LocalizableString.Settings.privacyPolicy.localized
		let privacyUrl = LocalizableString.url(privacy,
											   DisplayedLinks.privacyPolicy.linkURL).localized

		var str = LocalizableString.termsAlertDescription(termsUrl, privacyUrl).localized.attributedMarkdown!

		if let termsRange = str.range(of: terms) {
			str[termsRange].underlineStyle = .single
		}

		if let privacyRange = str.range(of: privacy) {
			str[privacyRange].underlineStyle = .single
		}

		return WXMAlertConfiguration(title: LocalizableString.termsAlertTitle.localized,
									 text: str,
									 canDismiss: false,
									 primaryButtons: [.init(title: LocalizableString.iUnderstand.localized,
															action: { [weak self] in
			self?.mainUseCase.setTermsOfUseAccepted()
			self?.showTermsPrompt = false
		})])
	}
	
	// MARK: Photos
	private func purgeSavedPhotos() {
		do {
			try photosUseCase.purgeImages()
		} catch {
			print("Error purging photos: \(error)")
		}
	}

	private func observePhotoUploads() {
		photosUseCase.uploadStartedPublisher.receive(on: DispatchQueue.main).sink { deviceId in
			LocalNotificationScheduler().postNotification(id: deviceId,
														  title: LocalizableString.PhotoVerification.uploadStartedSuccessfully.localized,
														  body: nil)
		}.store(in: &cancellableSet)

		photosUseCase.uploadCompletedPublisher.receive(on: DispatchQueue.main).sink { deviceId, count in
			LocalNotificationScheduler().postNotification(id: deviceId,
														  title: LocalizableString.PhotoVerification.uploadFinishedNotificationTitle(count).localized,
														  body: nil)

		}.store(in: &cancellableSet)

		photosUseCase.uploadErrorPublisher.receive(on: DispatchQueue.main).sink { deviceId, _ in
			if self.photosUseCase.getUploadState(deviceId: deviceId)  == .failed {
				LocalNotificationScheduler().postNotification(id: deviceId,
															  title: LocalizableString.PhotoVerification.uploadFailedNotificationFailedTitle.localized,
															  body: LocalizableString.PhotoVerification.uploadFailedNotificationFailedDescription.localized)
			}
		}.store(in: &cancellableSet)
	}

	// MARK: - Background tasks

	func performBackgroundProcess() {
		let alertsManager = StationAlertsManager(meUseCase: meUseCase,
												 stationNotificationsUseCase: stationNotificationsUseCase)
		Task {
			await alertsManager.checkForStationIssues()
		}
	}
}
