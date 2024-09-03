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
	func deviceRewardsTimeline(params: DevicesTimelineParams) throws -> AnyPublisher<DataResponse<NetworkDeviceRewardsTimelineResponse, NetworkErrorResponse>, Never>
	func deviceRewardsSummary(deviceId: String) throws -> AnyPublisher<DataResponse<NetworkDeviceRewardsSummaryResponse, NetworkErrorResponse>, Never>
	func deviceRewardsDetails(deviceId: String, date: String) throws -> AnyPublisher<DataResponse<NetworkDeviceRewardDetailsResponse, NetworkErrorResponse>, Never>
	func deviceRewardsBoosts(deviceId: String, code: String) throws -> AnyPublisher<DataResponse<NetworkDeviceRewardBoostsResponse, NetworkErrorResponse>, Never>
}

public struct DevicesTimelineParams {
	public let deviceId: String
	public let page: Int
	public let pageSize: Int?
	public let fromDate: String
	public let toDate: String?
	public let timezone: TimeZone?

	public init(deviceId: String,
				page: Int,
				pageSize: Int?,
				fromDate: String,
				toDate: String?,
				timezone: TimeZone?) {
		self.deviceId = deviceId
		self.page = page
		self.pageSize = pageSize
		self.fromDate = fromDate
		self.toDate = toDate
		self.timezone = timezone
	}
}
