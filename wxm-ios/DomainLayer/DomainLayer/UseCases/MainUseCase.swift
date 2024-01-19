//
//  MainUseCase.swift
//  DomainLayer
//
//  Created by Lampros Zouloumis on 1/9/22.
//

import WidgetKit
import Toolkit

public struct MainUseCase {
    private let userDefaultsRepository: UserDefaultsRepository
	private let keychainRepository: KeychainRepository

    public init(userDefaultsRepository: UserDefaultsRepository, keychainRepository: KeychainRepository) {
        self.userDefaultsRepository = userDefaultsRepository
		self.keychainRepository = keychainRepository
    }

	public func performMigrationsIfNeeded() {
		userDefaultsRepository.performMigrations()
		keychainRepository.performMigrations()
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

	public func shouldShowUpdatePrompt(for version: String, minimumVersion: String?) -> Bool {
		let lastAppVersionPrompt: String = userDefaultsRepository.getValue(for: UserDefaults.GenericKey.lastAppVersionPrompt.rawValue) ?? ""

		let shouldUpdate = shouldUpdate(version: version)
		let seenUpdatePrompt = lastAppVersionPrompt == version
		let shouldForceUpdate = shouldForceUpdate(minimumVersion: minimumVersion)

		return (!seenUpdatePrompt && shouldUpdate) || shouldForceUpdate
	}

	public func updateLastAppVersionPrompt(with version: String) {
		userDefaultsRepository.saveValue(key: UserDefaults.GenericKey.lastAppVersionPrompt.rawValue, value: version)
	}

	public func shouldForceUpdate(minimumVersion: String?) -> Bool {
		guard let minimumVersion,
			  let currentVersion = Bundle.main.releaseVersionNumber else {
			return false
		}

		return currentVersion.semVersionCompare(minimumVersion) == .orderedAscending
	}
}

private extension MainUseCase {
	func shouldUpdate(version: String) -> Bool {
		guard let currentVersion = Bundle.main.releaseVersionNumber else {
			return false
		}

		let result = currentVersion.semVersionCompare(version)
		return result == .orderedAscending
	}
}
