//
//  UserDevicesServiceTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 31/1/25.
//

import Testing
@testable import DataLayer
import DomainLayer

struct UserDevicesServiceTests {
	let service: UserDevicesService

	init() {
		service = .init(followStatesCacheManager: MockCacheManager(),
						userDevicesCacheManager: MockCacheManager())
	}

    @Test func initialState() {
		let cachedDevices = service.getCachedDevices()
		#expect(cachedDevices == nil)
    }

	@Test func initialFetch() async throws {
		let devices = try await service.getDevices(useCache: true).toAsync().result.get()
		#expect(devices.count == 2)

		let cachedDevices = service.getCachedDevices()
		#expect(cachedDevices?.count == 2)
		#expect(cachedDevices?.first?.id == devices.first?.id)
	}

	@Test func fetchSingle() async throws {
		let device = try await service.getUserDeviceById(deviceId: "124").toAsync().result.get()
		#expect(device != nil)
	}

	@Test func claimFlow() async throws {
		try await validateInitialState()

		let dummyDeviceBody = ClaimDeviceBody(serialNumber: "124",
											  location: .init(latitude: 0.0,
															  longitude: 0.0))

		let _ = try await service.claimDevice(claimDeviceBody: dummyDeviceBody).toAsync()

		let cachedDevices = service.getCachedDevices()
		#expect(cachedDevices == nil)
	}

	@Test func disClaimFlow() async throws {
		try await validateInitialState()

		let _ = try await service.disclaimDevice(serialNumber: "124").toAsync()

		let cachedDevices = service.getCachedDevices()
		#expect(cachedDevices == nil)
	}

	@Test func followFlow() async throws {
		try await validateInitialState()

		let _ = try await service.followStation(deviceId: "124").toAsync()

		let cachedDevices = service.getCachedDevices()
		#expect(cachedDevices == nil)
	}

	@Test func unfollowFlow() async throws {
		try await validateInitialState()

		let _ = try await service.unfollowStation(deviceId: "124").toAsync()

		let cachedDevices = service.getCachedDevices()
		#expect(cachedDevices == nil)
	}

	@Test func followState() async throws {
		let cachedDevices = service.getCachedDevices()
		#expect(cachedDevices == nil)

		let deviceId = "45ccb1e0-77df-11ed-960f-d7d4cf200cc9"
		let state = try await service.getFollowState(deviceId: deviceId).get()
		#expect(state?.deviceId == deviceId)

		try await validateInitialState()
	}

	@Test func getFollowStates() async throws {
		let cachedDevices = service.getCachedDevices()
		#expect(cachedDevices == nil)

		let deviceId = "45ccb1e0-77df-11ed-960f-d7d4cf200cc9"
		let states = try await service.getFollowStates().get()
		#expect(states?.count == 2)
		#expect(states?.first?.deviceId == deviceId)

		try await validateInitialState()
	}

	@Test func setLocationFlow() async throws {
		try await validateInitialState()

		let _ = try await service.setDeviceLocationById(deviceId: "124",
														lat: 0.0,
														lon: 0.0).toAsync()

		let cachedDevices = service.getCachedDevices()
		#expect(cachedDevices == nil)
	}

	@Test func setFriendlyNameFlow() async throws {
		try await validateInitialState()

		let _ = try await service.setFriendlyName(deviceId: "124", name: "Name").toAsync()

		let cachedDevices = service.getCachedDevices()
		#expect(cachedDevices == nil)
	}

	@Test func deleteFriendlyNameFlow() async throws {
		try await validateInitialState()

		let _ = try await service.deleteFriendlyName(deviceId: "124").toAsync()

		let cachedDevices = service.getCachedDevices()
		#expect(cachedDevices == nil)
	}

}

private extension UserDevicesServiceTests {
	func validateInitialState() async throws {
		let devices = try await service.getDevices(useCache: true).toAsync().result.get()
		#expect(devices.count == 2)

		let cachedDevices = service.getCachedDevices()
		#expect(cachedDevices?.count == 2)
	}
}
