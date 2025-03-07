//
//  RewardsTimelineUseCaseTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 7/3/25.
//

import Testing
@testable import DomainLayer
import Toolkit

struct RewardsTimelineUseCaseTests {

	let devicesRepository: MockDevicesRepositoryImpl = .init()
	let meRepository: MockMeRepositoryImpl = .init()
	let useCase: RewardsTimelineUseCase
	let cancellableWrapper: CancellableWrapper = .init()

	init() {
		self.useCase = RewardsTimelineUseCase(repository: devicesRepository, meRepository: meRepository)
	}

	@Test func getRewardsTimeline() async throws {
		let timeline = try await useCase.getTimeline(deviceId: "124",
													 page: 0,
													 fromDate: "",
													 toDate: "").get()
		return try await confirmation { confirm in
			try devicesRepository.deviceRewardsTimeline(params: .init(deviceId: "124",
																	  page: 0,
																	  pageSize: nil,
																	  fromDate: "",
																	  toDate: "",
																	  timezone: nil)).sink { response in
				let res = try! response.result.get()
				#expect(timeline == res)
				confirm()
			}.store(in: &cancellableWrapper.cancellableSet)
		}
    }

	@Test func followState() async throws {
		let state = try await useCase.getFollowState(deviceId: "124").get()
		let repositoryState = try await meRepository.getDeviceFollowState(deviceId: "124").get()
		#expect(state == repositoryState)
	}

	@Test func getRewardDetails() async throws {
		let details = try await useCase.getRewardDetails(deviceId: "124", date: "").get()

		return try await confirmation { confirm in
			try devicesRepository.deviceRewardsDetails(deviceId: "124", date: "").sink { response in
				let res = try! response.result.get()
				#expect(details == res)
				confirm()
			}.store(in: &cancellableWrapper.cancellableSet)
		}
	}

	@Test func getRewardBoosts() async throws {
		let boosts = try await useCase.getRewardBoosts(deviceId: "124", code: "").get()

		return try await confirmation { confirm in
			try devicesRepository.deviceRewardsBoosts(deviceId: "124", code: "").sink { response in
				let res = try! response.result.get()
				#expect(boosts == res)
				confirm()
			}.store(in: &cancellableWrapper.cancellableSet)
		}
	}

}
