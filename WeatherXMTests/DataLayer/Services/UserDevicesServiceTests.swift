//
//  UserDevicesServiceTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 31/1/25.
//

import Testing
@testable import DataLayer

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

}
