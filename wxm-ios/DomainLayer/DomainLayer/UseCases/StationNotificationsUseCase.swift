//
//  StationNotificationsUseCase.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 9/7/25.
//

import Foundation

private typealias StationOptions = [StationNotificationsTypes: Bool]
private typealias Stations = [String: StationOptions]
public struct StationNotificationsUseCase: StationNotificationsUseCaseApi {
	private let userDefaultsRepository: UserDefaultsRepository
	private let stationsUDKey = UserDefaults.GenericKey.stationNotificationOptions.rawValue
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

	public func setNotificationEnabled(_ enabled: Bool, deviceId: String, for type: StationNotificationsTypes) {
		var stations = getStations() ?? [:]
		guard var options = stations[deviceId] else {
			var options: StationOptions = [:]
			options[type] = enabled
			stations[deviceId] = options
			saveStations(stations)
			return
		}

		options[type] = enabled
		stations[deviceId] = options
		saveStations(stations)
	}

	public func isNotificationEnabled(_ type: StationNotificationsTypes, deviceId: String) -> Bool {
		let options = getStations()?[deviceId]
		return options?[type] ?? false
	}
}

private extension StationNotificationsUseCase {
	func getStations() -> Stations? {
		guard let stationsDict: [String: [String: Bool]] = userDefaultsRepository.getValue(for: stationsUDKey) else {
			return nil
		}

		return Dictionary(uniqueKeysWithValues: stationsDict.compactMap({ key, value in
			let stationOptions: StationOptions = Dictionary(uniqueKeysWithValues: value.compactMap({ key, value in
				guard let key = StationNotificationsTypes(rawValue: key) else {
					return nil
				}
				
				return (key, value)
			}))

			return (key, stationOptions)
		}))
	}

	func saveStations(_ stations: Stations) {
		let convertedDict: [String: [String: Bool]] = Dictionary(uniqueKeysWithValues: stations.map({ key, value in
			let convertedOptions: [String: Bool] = Dictionary(uniqueKeysWithValues: value.map({ key, value in
				(key.rawValue, value)
			}))

			return (key, convertedOptions)
		}))

		userDefaultsRepository.saveValue(key: stationsUDKey, value: convertedDict)
	}
}
