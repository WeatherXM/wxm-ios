//
//  StationNotificationsUseCase.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 9/7/25.
//

import Foundation

private typealias StationOptions = [StationNotificationsTypes: Bool]
private typealias Stations = [String: StationOptions]
private typealias EnabledStations = [String: Bool]

public struct StationNotificationsUseCase: StationNotificationsUseCaseApi {
	private let userDefaultsRepository: UserDefaultsRepository
	private let stationsUDKey = UserDefaults.GenericKey.stationNotificationOptions.rawValue
	private let notificationsEnabledUDKey = UserDefaults.GenericKey.stationNotificationEnabled.rawValue

	public init(userDefaultsRepository: UserDefaultsRepository) {
		self.userDefaultsRepository = userDefaultsRepository
	}

	public func areNotificationsEnabledForDevice(_ deviceId: String) -> Bool {
		let devices: EnabledStations? = userDefaultsRepository.getValue(for: notificationsEnabledUDKey)
		guard let isEnabled = devices?[deviceId] else {
			return true
		}

		return isEnabled
	}

	public func setNotificationsForDevice(_ deviceId: String, enabled: Bool) {
		var enabledStations: EnabledStations = userDefaultsRepository.getValue(for: notificationsEnabledUDKey) ?? [:]
		enabledStations[deviceId] = enabled
		userDefaultsRepository.saveValue(key: notificationsEnabledUDKey, value: enabledStations)
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
		return options?[type] ?? true
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
