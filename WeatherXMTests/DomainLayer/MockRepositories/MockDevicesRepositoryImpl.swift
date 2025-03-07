//
//  MockDevicesRepositoryImpl.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 7/3/25.
//

import Foundation
@testable import DomainLayer
import Combine
import Alamofire

class MockDevicesRepositoryImpl {

}

extension MockDevicesRepositoryImpl: DevicesRepository {
	func devices() throws -> AnyPublisher<DataResponse<[NetworkDevicesResponse], NetworkErrorResponse>, Never> {
		let device = NetworkDevicesResponse()
		let response = DataResponse<[NetworkDevicesResponse], NetworkErrorResponse>(request: nil,
																					response: nil,
																					data: nil,
																					metrics: nil,
																					serializationDuration: 0,
																					result: .success([device]))
		return Just(response).eraseToAnyPublisher()
	}

	func deviceById(deviceId: String) throws -> AnyPublisher<DataResponse<NetworkDevicesResponse, NetworkErrorResponse>, Never> {
		let device = NetworkDevicesResponse()
		let response = DataResponse<NetworkDevicesResponse, NetworkErrorResponse>(request: nil,
																				  response: nil,
																				  data: nil,
																				  metrics: nil,
																				  serializationDuration: 0,
																				  result: .success(device))
		return Just(response).eraseToAnyPublisher()
	}

	func deviceRewardsTimeline(params: DevicesTimelineParams) throws -> AnyPublisher<DataResponse<NetworkDeviceRewardsTimelineResponse, NetworkErrorResponse>, Never> {
		let timelineResponse = NetworkDeviceRewardsTimelineResponse(data: nil, totalPages: 0, hasNextPage: false)
		let response = DataResponse<NetworkDeviceRewardsTimelineResponse, NetworkErrorResponse>(request: nil,
																								response: nil,
																								data: nil,
																								metrics: nil,
																								serializationDuration: 0,
																								result: .success(timelineResponse))
		return Just(response).eraseToAnyPublisher()
	}

	func deviceRewardsSummary(deviceId: String) throws -> AnyPublisher<DataResponse<NetworkDeviceRewardsSummaryResponse, NetworkErrorResponse>, Never> {
		let summaryResponse = NetworkDeviceRewardsSummaryResponse(totalRewards: 0.0, latest: nil, timeline: nil)
		let response = DataResponse<NetworkDeviceRewardsSummaryResponse, NetworkErrorResponse>(request: nil,
																							   response: nil,
																							   data: nil,
																							   metrics: nil,
																							   serializationDuration: 0,
																							   result: .success(summaryResponse))
		return Just(response).eraseToAnyPublisher()
	}

	func deviceRewardsDetails(deviceId: String, date: String) throws -> AnyPublisher<DataResponse<NetworkDeviceRewardDetailsResponse, NetworkErrorResponse>, Never> {
		let detailsResponse = NetworkDeviceRewardDetailsResponse(timestamp: nil, totalDailyReward: nil, annotations: nil, base: nil, boost: nil, rewardSplit: nil)
		let response = DataResponse<NetworkDeviceRewardDetailsResponse, NetworkErrorResponse>(request: nil,
																							  response: nil,
																							  data: nil,
																							  metrics: nil,
																							  serializationDuration: 0,
																							  result: .success(detailsResponse))
		return Just(response).eraseToAnyPublisher()
	}

	func deviceRewardsBoosts(deviceId: String, code: String) throws -> AnyPublisher<DataResponse<NetworkDeviceRewardBoostsResponse, NetworkErrorResponse>, Never> {
		let boostsResponse = NetworkDeviceRewardBoostsResponse(code: nil, metadata: nil, details: nil)
		let response = DataResponse<NetworkDeviceRewardBoostsResponse, NetworkErrorResponse>(request: nil,
																							 response: nil,
																							 data: nil,
																							 metrics: nil,
																							 serializationDuration: 0,
																							 result: .success(boostsResponse))
		return Just(response).eraseToAnyPublisher()
	}
}
