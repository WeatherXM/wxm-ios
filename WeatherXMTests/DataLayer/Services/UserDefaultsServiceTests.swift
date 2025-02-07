//
//  UserDefaultsServiceTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 28/1/25.
//

import Testing
@testable import DataLayer

@Suite(.serialized)
struct UserDefaultsServiceTests {

	private let service = UserDefaultsService()

    @Test func saveValue() {
		let key = "testKey"
		let value = "testValue"

		// Store
		service.save(value: value, key: key)
		let storedValue: String? = service.get(key: key)
		#expect(storedValue == value)


		// Remove
		service.remove(key: key)
		let removedValue: String? = service.get(key: key)
		#expect(removedValue == nil)
    }

	@Test func saveUserValueAndClearUserSensitiveData() {
		let key = UserDefaults.userGeneratedKeys.first
		let value = "testValue"

		service.save(value: value, key: key!)
		let storedValue: String? = service.get(key: key!)
		#expect(storedValue == value)

		service.clearUserSensitiveData()
		let removedValue: String? = service.get(key: key!)
		#expect(removedValue == nil)
	}

	@Test func defaultWeatherFieldsAndClearUserSensitiveData() {
		let weatherKeys = UserDefaults.WeatherUnitKey.allCases
		weatherKeys.forEach { key in
			let unit = service.saveDefaultUnitProtocolFor(key: key.rawValue)
			let storedUnit = service.getUnitsProtocol(key: key.rawValue)
			#expect(unit?.key == storedUnit?.key)
			#expect(unit?.value == storedUnit?.value)
		}

		service.clearUserSensitiveData()
		weatherKeys.forEach { key in
			let storedUnit = service.getUnitsProtocol(key: key.rawValue)
			#expect(storedUnit == nil)
		}
	}
}
