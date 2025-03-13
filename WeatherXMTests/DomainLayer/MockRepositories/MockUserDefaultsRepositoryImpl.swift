//
//  MockUserDefaultsRepositoryImpl.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 7/3/25.
//

import Foundation
@testable import DomainLayer

class MockUserDefaultsRepositoryImpl {
	private(set) var userSensitiveDataCleared = false
	private var dictionary: [String: Any] = [:]
}

extension MockUserDefaultsRepositoryImpl: UserDefaultsRepository {
	func readWeatherUnit(key: String) -> UnitsProtocol? {
		dictionary[key] as? UnitsProtocol
	}
	
	func saveDefaultUnitForKey(key: String) -> UnitsProtocol? {
		dictionary[key] = TemperatureUnitsEnum.celsius
		return dictionary[key] as? UnitsProtocol
	}
	
	func saveWeatherUnit(unitProtocol: UnitsProtocol) {
		dictionary[unitProtocol.key] = unitProtocol
	}
	
	func saveValue<T>(key: String, value: T) {
		dictionary[key] = value
	}
	
	func getValue<T>(for key: String) -> T? {
		dictionary[key] as? T
	}
	
	func clearUserSensitiveData() {
		userSensitiveDataCleared = true
	}
}
