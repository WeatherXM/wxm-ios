//
//  DevicesRepository.swift
//  DomainLayer
//
//  Created by Hristos Condrea on 17/5/22.
//

import Alamofire
import Combine

public protocol DevicesRepository {
    func devices() throws -> AnyPublisher<DataResponse<[NetworkDevicesResponse], NetworkErrorResponse>, Never>
    func deviceById(deviceId: String) throws -> AnyPublisher<DataResponse<NetworkDevicesResponse, NetworkErrorResponse>, Never>
	func deviceRewardsTimeline(deviceId: String, page: Int, pageSize: Int?, timezone: String, fromDate: String, toDate: String?) throws -> AnyPublisher<DataResponse<NetworkDeviceRewardsTimelineResponse, NetworkErrorResponse>, Never>
	func deviceRewardsSummary(deviceId: String) throws -> AnyPublisher<DataResponse<NetworkDeviceRewardsSummaryResponse, NetworkErrorResponse>, Never>
	func deviceRewardsDetails(deviceId: String) throws -> AnyPublisher<DataResponse<NetworkDeviceRewardDetailsResponse, NetworkErrorResponse>, Never>
}
