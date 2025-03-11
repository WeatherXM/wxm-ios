//
//  DeviceDetailsUseCaseTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 11/3/25.
//

import Testing
@testable import DomainLayer

struct DeviceDetailsUseCaseTests {
	let meRepository: MockMeRepositoryImpl = .init()
	let explorerRepository: MockExplorerRepositoryImpl = .init()
	let keychainRepository: MockKeychainRepositoryImpl = .init()
	let useCase: DeviceDetailsUseCase

	init() {
		self.useCase = .init(meRepository: meRepository,
							 explorerRepository: explorerRepository,
							 keychainRepository: keychainRepository)

	}

    @Test func getDeviceDetailsById() async throws {
		// Should be public device
		var res = try await useCase.getDeviceDetailsById(deviceId: "",
														 cellIndex: "index").get()
		#expect(res.cellIndex == "index")

		// Should be user device
		res = try await useCase.getDeviceDetailsById(deviceId: MockMeRepositoryImpl.Constants.followedDeviceId.rawValue,
														 cellIndex: "index").get()
		#expect(res.cellIndex == "")
    }

	@Test func followStation() async throws {
		let res = try await useCase.followStation(deviceId: "124").get()
		#expect(res != nil)
	}

	@Test func unfollowStation() async throws {
		let res = try await useCase.unfollowStation(deviceId: "124").get()
		#expect(res != nil)
	}

	@Test func getFollowState() async throws {
		let res = try await useCase.getDeviceFollowState(deviceId: MockMeRepositoryImpl.Constants.followedDeviceId.rawValue).get()
		#expect(res?.relation == .followed)
	}
}
