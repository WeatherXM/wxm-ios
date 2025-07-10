//
//  StationNotificationsUseCase.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 9/7/25.
//

import Foundation

private typealias StationOptions = [StationNotificationsTypes: Bool]
public struct StationNotificationsUseCase: StationNotificationsUseCaseApi {
	private let userDefaultsRepository: UserDefaultsRepository
	private let udKey = UserDefaults.GenericKey.stationNotificationOptions.rawValue
	private let notificationsEnabledUDKey = UserDefaults.GenericKey.stationNotificationEnabled.rawValue

	public init(userDefaultsRepository: UserDefaultsRepository) {
		self.userDefaultsRepository = userDefaultsRepository
	}

	public func areNotificationsEnalbedForDevice(_ deviceId: String) -> Bool {
		let deviceIds: [String]? = userDefaultsRepository.getValue(for: notificationsEnabledUDKey)
		return deviceIds?.contains(deviceId) ?? false
	}

	public func setNotificationsForDevice(_ deviceId: String, enabled: Bool) {
		let deviceIdsArray: [String] = userDefaultsRepository.getValue(for: notificationsEnabledUDKey) ?? []
		var deviceIds: Set<String> = Set(deviceIdsArray)

		if enabled {
			deviceIds.insert(deviceId)
		} else {
			deviceIds.remove(deviceId)
		}

		userDefaultsRepository.saveValue(key: notificationsEnabledUDKey, value: Array(deviceIds))
	}

	public func setNotificationEnabled(_ enabled: Bool, for type: StationNotificationsTypes) {
		guard var options = getOptions() else {
			var options: StationOptions = [:]
			options[type] = enabled
			saveOptions(options)
			return
		}

		options[type] = enabled
		saveOptions(options)
	}

	public func isNotificationEnabled(_ type: StationNotificationsTypes) -> Bool {
		let options = getOptions()
		return options?[type] ?? false
	}
}

private extension StationNotificationsUseCase {
	func saveOptions(_ options: StationOptions) {
		let convertedDict = Dictionary(uniqueKeysWithValues: options.map({ key, value in
			(key.rawValue, value)
		}))

		userDefaultsRepository.saveValue(key: udKey, value: convertedDict)
	}

	func getOptions() -> StationOptions? {
		guard let optionsDict: [String: Bool] = userDefaultsRepository.getValue(for: udKey) else {
			return nil
		}
		
		return Dictionary(uniqueKeysWithValues: optionsDict.compactMap({ key, value in
			guard let key = StationNotificationsTypes(rawValue: key) else {
				return nil
			}

			return (key, value)
		}))
	}
}
