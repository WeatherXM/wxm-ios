//
//  StationNotificationsUseCaseTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 10/7/25.
//

import Testing
@testable import DomainLayer

struct StationNotificationsUseCaseTests {
	let userDefaultsRepository: MockUserDefaultsRepositoryImpl = .init()
	let useCase: StationNotificationsUseCase

	init() {
		self.useCase = .init(userDefaultsRepository: userDefaultsRepository)
	}

	@Test func notificationsEnabledDefaultTrue() {
		// No value set, should default to true
		#expect(useCase.areNotificationsEnabledForDevice("device1") == true)
	}

	@Test func setNotificationsForDevice() {
		useCase.setNotificationsForDevice("device1", enabled: false)
		#expect(useCase.areNotificationsEnabledForDevice("device1") == false)
		useCase.setNotificationsForDevice("device1", enabled: true)
		#expect(useCase.areNotificationsEnabledForDevice("device1") == true)
	}

	@Test func setAndGetNotificationTypeEnabled() {
		let deviceId = "device2"
		#expect(useCase.isNotificationEnabled(.activity, deviceId: deviceId) == true)
		useCase.setNotificationEnabled(false, deviceId: deviceId, for: .activity)
		#expect(useCase.isNotificationEnabled(.activity, deviceId: deviceId) == false)
		useCase.setNotificationEnabled(true, deviceId: deviceId, for: .activity)
		#expect(useCase.isNotificationEnabled(.activity, deviceId: deviceId) == true)
	}

	@Test func notificationTypeDefaultTrue() {
		let deviceId = "device3"
		#expect(useCase.isNotificationEnabled(.battery, deviceId: deviceId) == true)
	}

	@Test func multipleTypesPerDevice() {
		let deviceId = "device4"
		useCase.setNotificationEnabled(false, deviceId: deviceId, for: .activity)
		useCase.setNotificationEnabled(true, deviceId: deviceId, for: .battery)
		#expect(useCase.isNotificationEnabled(.activity, deviceId: deviceId) == false)
		#expect(useCase.isNotificationEnabled(.battery, deviceId: deviceId) == true)
		#expect(useCase.isNotificationEnabled(.firmwareUpdate, deviceId: deviceId) == true)
	}
}
