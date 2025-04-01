//
//  RewardsTimelineUseCaseApi.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 1/4/25.
//

public protocol RewardsTimelineUseCaseApi: Sendable {
	func getTimeline(deviceId: String, page: Int, fromDate: String, toDate: String, timezone: TimeZone?) async throws -> Result<NetworkDeviceRewardsTimelineResponse?, NetworkErrorResponse>
	func getFollowState(deviceId: String) async throws -> Result<UserDeviceFollowState?, NetworkErrorResponse>
	func getRewardDetails(deviceId: String, date: String) async throws -> Result<NetworkDeviceRewardDetailsResponse?, NetworkErrorResponse>
	func getRewardBoosts(deviceId: String, code: String) async throws -> Result<NetworkDeviceRewardBoostsResponse?, NetworkErrorResponse>
}

