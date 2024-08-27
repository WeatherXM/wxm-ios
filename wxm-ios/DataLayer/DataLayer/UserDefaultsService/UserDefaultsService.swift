//
//  UserDefaultsService.swift
//  DataLayer
//
//  Created by Lampros Zouloumis on 1/9/22.
//

import DomainLayer
import Foundation
import Toolkit

public struct UserDefaultsService: PersistCacheManager {
	private let userDefaults: UserDefaults?
	
	init() {
		guard let appGroup: String = Bundle.main.getConfiguration(for: .appGroup) else {
			self.userDefaults = nil
			return
		}
		
		self.userDefaults = UserDefaults(suiteName: "\(appGroup)")
	}
	
	// MARK: - PersistCacheManager
	public func save<T>(value: T, key: String) {
		userDefaults?.set(value, forKey: key)
	}
	
	public func get<T>(key: String) -> T? {
		userDefaults?.value(forKey: key) as? T
	}
	
	public func remove(key: String) {
		userDefaults?.removeObject(forKey: key)
	}
	
	func clearUserSensitiveData() {
		UserDefaults.userGeneratedKeys.forEach { remove(key: $0 ) }
	}
	
	func getUnitsProtocol(key: String) -> UnitsProtocol? {
		if let rawValue = userDefaults?.string(forKey: key) {
			return UnitsObjectFactory().spawn(from: rawValue)
		}
		return nil
	}
	
	func saveDefaultUnitProtocolFor(key: String) -> UnitsProtocol? {
		if let unitProtocol = UnitsObjectFactory().spawnDefault(from: key) {
			save(value: unitProtocol.value, key: unitProtocol.key)
			return unitProtocol
		}
		return nil
	}
	
	struct UnitsObjectFactory {
		internal func spawn(from rawValue: String) -> UnitsProtocol? {
			if let temperatureUnitsProtocol = TemperatureUnitsEnum(rawValue: rawValue) {
				return temperatureUnitsProtocol
			} else if let precipitationUnitsProtocol = PrecipitationUnitsEnum(rawValue: rawValue) {
				return precipitationUnitsProtocol
			} else if let windSpeedUnitsProtocol = WindSpeedUnitsEnum(rawValue: rawValue) {
				return windSpeedUnitsProtocol
			} else if let windDirectionUnitsProtocol = WindDirectionUnitsEnum(rawValue: rawValue) {
				return windDirectionUnitsProtocol
			} else if let pressureUnitsProtocol = PressureUnitsEnum(rawValue: rawValue) {
				return pressureUnitsProtocol
			}
			return nil
		}
		
		func spawnDefault(from key: String) -> UnitsProtocol? {
			switch UserDefaults.WeatherUnitKey(rawValue: key) {
				case .temperature:
					return TemperatureUnitsEnum.celsius
				case .precipitation:
					return PrecipitationUnitsEnum.millimeters
				case .windSpeed:
					return WindSpeedUnitsEnum.kilometersPerHour
				case .windDirection:
					return WindDirectionUnitsEnum.cardinal
				case .pressure:
					return PressureUnitsEnum.hectopascal
				default:
					return nil
			}
		}
	}
}
