//
//  RewardsUseCaseTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 7/3/25.
//

import Testing
@testable import DomainLayer
import Toolkit

struct RewardsUseCaseTests {
	let repository: MockDevicesRepositoryImpl = .init()
	let useCase: RewardsUseCase
	let cancellableWrapper: CancellableWrapper = .init()

	init() {
		self.useCase = RewardsUseCase(devicesRepository: repository)
	}

	@Test func getDeviceRewardsSummary() async throws {
		let rewardsSummary = try await useCase.getDeviceRewardsSummary(deviceId: "123").get()
		return try await confirmation { confirm in
			try repository.deviceRewardsSummary(deviceId: "124").sink { response in
				let res = try! response.result.get()
				#expect(res == rewardsSummary)
				confirm()
			}.store(in: &cancellableWrapper.cancellableSet)
		}
    }

}
