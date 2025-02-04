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

	@Test func claimFlow() async throws {
		let devices = try await service.getDevices(useCache: true).toAsync().result.get()
		#expect(devices.count == 2)

		var cachedDevices = service.getCachedDevices()
		#expect(cachedDevices?.count == 2)

		let dummyDeviceBody = ClaimDeviceBody(serialNumber: "124",
											  location: .init(latitude: 0.0,
															  longitude: 0.0))

		let result = try await service.claimDevice(claimDeviceBody: dummyDeviceBody).toAsync().result

		cachedDevices = service.getCachedDevices()
		#expect(cachedDevices == nil)
	}
}
