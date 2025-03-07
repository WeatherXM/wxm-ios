//
//  WidgetUseCaseTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 6/3/25.
//

import Testing
@testable import DomainLayer
import Toolkit

struct WidgetUseCaseTests {
	let meRepository: MockMeRepositoryImpl = .init()
	let keychainRepository: MockKeychainRepositoryImpl = .init()
	let useCase: WidgetUseCase
	private let cancellableWrapper: CancellableWrapper = .init()

	init() {
		self.useCase = .init(meRepository: meRepository, keychainRepository: keychainRepository)
	}

    @Test func isLoggedIn() {
		#expect(useCase.isUserLoggedIn == keychainRepository.isUserLoggedIn())
    }

	@Test func cachedDevices() {
		let cachedDevices = useCase.getCachedDevices()
		let repositoryDevices = meRepository.getCachedDevices()
		#expect(cachedDevices?.count == repositoryDevices?.count)
		#expect(cachedDevices?.first?.name == repositoryDevices?.first?.name)
	}

	@MainActor
	@Test func devices() async throws {
		let devices = try await useCase.getDevices().get()
		return try await confirmation { confim in
			try meRepository.getDevices(useCache: false).sink { response in
				let repositoryDevices = try! response.result.get()
				#expect(repositoryDevices.count == devices.count)
				confim()
			}.store(in: &cancellableWrapper.cancellableSet)
		}
	}

	@Test func followState() async throws {
		let state = try await useCase.getDeviceFollowState(deviceId: "123").get()
		let repositoryState = try await meRepository.getDeviceFollowState(deviceId: "123").get()
		#expect(state == repositoryState)
	}
}
