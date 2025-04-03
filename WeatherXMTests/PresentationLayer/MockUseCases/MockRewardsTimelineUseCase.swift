//
//  MockRewardsTimelineUseCase.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 2/4/25.
//

import DomainLayer

struct MockRewardsTimelineUseCase: RewardsTimelineUseCaseApi {
	func getTimeline(deviceId: String,
					 page: Int,
					 fromDate: String,
					 toDate: String,
					 timezone: TimeZone?) async throws -> Result<NetworkDeviceRewardsTimelineResponse?, NetworkErrorResponse> {
		let summary = NetworkDeviceRewardsSummary(timestamp: .now,
												  baseReward: 12.0,
												  totalBoostReward: 14.0,
												  totalReward: 20.0,
												  baseRewardScore: 2,
												  annotationSummary: nil)
		let timeline = NetworkDeviceRewardsTimelineResponse(data: [summary],
															totalPages: nil,
															hasNextPage: nil)
		return .success(timeline)
	}
	
	func getFollowState(deviceId: String) async throws -> Result<UserDeviceFollowState?, NetworkErrorResponse> {
		.success(nil)
	}
	
	func getRewardDetails(deviceId: String, date: String) async throws -> Result<NetworkDeviceRewardDetailsResponse?, NetworkErrorResponse> {
		let annotations: [RewardAnnotation] = [.init(severity: .error,
													 group: .noLocationData,
													 title: nil,
													 message: nil,
													 docUrl: nil)]
		let base: NetworkDeviceRewardDetailsResponse.Base = .init(actualReward: 2.2,
																  rewardScore: 45,
																  maxReward: 4.0,
																  qodScore: 65,
																  cellCapacity: nil,
																  cellPosition: nil)

		let response = NetworkDeviceRewardDetailsResponse(timestamp: nil,
														  totalDailyReward: nil,
														  annotations: annotations,
														  base: base,
														  boost: nil,
														  rewardSplit: nil)
		return .success(response)
	}
	
	func getRewardBoosts(deviceId: String, code: String) async throws -> Result<NetworkDeviceRewardBoostsResponse?, NetworkErrorResponse> {
		let boosts = NetworkDeviceRewardBoostsResponse(code: nil, metadata: nil, details: nil)
		return .success(boosts)
	}
}
