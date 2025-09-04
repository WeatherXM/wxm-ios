//
//  MainUseCase.swift
//  DomainLayer
//
//  Created by Lampros Zouloumis on 1/9/22.
//

import WidgetKit
import Toolkit
import Combine

public class MainUseCase: @unchecked Sendable, MainUseCaseApi {
	public var userLoggedInStateNotificationPublisher: NotificationCenter.Publisher

	private let mainRepository: MainRepository
    private let userDefaultsRepository: UserDefaultsRepository
	private let keychainRepository: KeychainRepository
	private let meRepository: MeRepository
	private var cancellableSet: Set<AnyCancellable> = .init()

	public init(mainRepository: MainRepository,
				userDefaultsRepository: UserDefaultsRepository,
				keychainRepository: KeychainRepository,
				meRepository: MeRepository) {
		self.mainRepository = mainRepository
        self.userDefaultsRepository = userDefaultsRepository
		self.keychainRepository = keychainRepository
		self.meRepository = meRepository
		userLoggedInStateNotificationPublisher = keychainRepository.userLoggedInStateNotificationPublisher

		FirebaseManager.shared.fcmTokenPublisher?.sink { [weak self] _ in
			self?.setFCMTokenIfNeeded()
		}.store(in: &cancellableSet)

		mainRepository.initializeHttpMonitor()
    }

    public func saveOrUpdateWeatherMetric(unitProtocol: UnitsProtocol) {
        userDefaultsRepository.saveWeatherUnit(unitProtocol: unitProtocol)
		WidgetCenter.shared.reloadAllTimelines()
    }

    public func readOrCreateWeatherMetric(key: String) -> UnitsProtocol? {
        let unitsProtocol = userDefaultsRepository.readWeatherUnit(key: key)
        if unitsProtocol == nil {
            guard let returnedUnitsProtocol = userDefaultsRepository.saveDefaultUnitForKey(key: key) else {
                return nil
            }
            return returnedUnitsProtocol
        }
        return unitsProtocol
    }

    public func saveValue<T>(key: String, value: T) {
        userDefaultsRepository.saveValue(key: key, value: value)
    }

    public func getValue<T>(key: String) -> T? {
        userDefaultsRepository.getValue(for: key)
    }

	public func shouldShowUpdatePrompt(for version: String,
									   minimumVersion: String?,
									   currentVersion: String?) -> Bool {
		let currentVersion = currentVersion ?? Bundle.main.releaseVersionNumber
		let lastAppVersionPrompt: String = userDefaultsRepository.getValue(for: UserDefaults.GenericKey.lastAppVersionPrompt.rawValue) ?? ""

		let shouldUpdate = shouldUpdate(version: version,
										currentVersion: currentVersion)
		let seenUpdatePrompt = lastAppVersionPrompt == version
		let shouldForceUpdate = shouldForceUpdate(minimumVersion: minimumVersion,
												  currentVersion: currentVersion)

		return (!seenUpdatePrompt && shouldUpdate) || shouldForceUpdate
	}

	public func updateLastAppVersionPrompt(with version: String) {
		userDefaultsRepository.saveValue(key: UserDefaults.GenericKey.lastAppVersionPrompt.rawValue, value: version)
	}

	public func shouldForceUpdate(minimumVersion: String?,
								  currentVersion: String?) -> Bool {
		guard let minimumVersion,
			  let currentVersion = currentVersion ?? Bundle.main.releaseVersionNumber else {
			return false
		}

		return currentVersion.semVersionCompare(minimumVersion) == .orderedAscending
	}

	public func setTermsOfUseAccepted() {
		userDefaultsRepository.saveValue(key: UserDefaults.GenericKey.termsOfUseAcceptedTimestamp.rawValue, value: Date.now)
	}

	public func areTermsOfUseAccepted() -> Bool {
		let timestamp: Date? = userDefaultsRepository.getValue(for: UserDefaults.GenericKey.termsOfUseAcceptedTimestamp.rawValue)
		return timestamp != nil
	}

	public func shouldShowOnboarding() -> Bool {
		true
	}

	public func marκOnboardingAsShown() {
		userDefaultsRepository.saveValue(key: UserDefaults.GenericKey.onboardingIsShown.rawValue, value: true)
	}
}

private extension MainUseCase {
	func shouldUpdate(version: String,
					  currentVersion: String?) -> Bool {
		guard let currentVersion else {
			return false
		}

		let result = currentVersion.semVersionCompare(version)
		return result == .orderedAscending
	}

	func setFCMTokenIfNeeded() {
		Task {
			guard keychainRepository.isUserLoggedIn(),
				  let token = FirebaseManager.shared.getFCMToken() else {
				return
			}

			let installationId = await FirebaseManager.shared.getInstallationId()
			try? meRepository.setNotificationsFcmToken(installationId: installationId, token: token).sink { response in
				print(response)
			}.store(in: &cancellableSet)
		}
	}
}
