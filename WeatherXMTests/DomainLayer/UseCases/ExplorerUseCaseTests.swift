//
//  ExplorerUseCaseTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 10/3/25.
//

import Testing
@testable import DomainLayer

struct ExplorerUseCaseTests {
	let explorerRepository: MockExplorerRepositoryImpl = .init()
	let devicesRepository: MockDevicesRepositoryImpl = .init()
	let meRepository: MockMeRepositoryImpl = .init()
	let deviceLocationRepository: MockDeviceLocationRepositoryImpl = .init()
	let useCase: ExplorerUseCase


	init() {
		self.useCase = ExplorerUseCase(explorerRepository: explorerRepository,
									   devicesRepository: devicesRepository,
									   meRepository: meRepository,
									   deviceLocationRepository: deviceLocationRepository)
	}

    @Test func s() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }

}
