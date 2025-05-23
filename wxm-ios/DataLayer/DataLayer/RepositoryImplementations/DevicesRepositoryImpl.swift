//
//  DevicesRepositoryImpl.swift
//  DataLayer
//
//  Created by Danae Kikue Dimou on 18/5/22.
//

import Alamofire
import Combine
@preconcurrency import DomainLayer
import Foundation
import Toolkit

public struct DevicesRepositoryImpl: DevicesRepository {

    private let cancellables: CancellableWrapper = .init()

    public func devices() throws -> AnyPublisher<DataResponse<[NetworkDevicesResponse], NetworkErrorResponse>, Never> {
        let urlRequest = try DevicesApiRequestBuilder.devices.asURLRequest()
        return ApiClient.shared.requestCodable(urlRequest)
    }

    public func deviceById(deviceId: String) throws -> AnyPublisher<DataResponse<NetworkDevicesResponse, NetworkErrorResponse>, Never> {
        let urlRequest = try DevicesApiRequestBuilder.deviceById(deviceId: deviceId).asURLRequest()
        return ApiClient.shared.requestCodable(urlRequest)
    }

	public func deviceRewardsTimeline(params: DevicesTimelineParams) throws -> AnyPublisher<DataResponse<NetworkDeviceRewardsTimelineResponse, NetworkErrorResponse>, Never> {
		let builder = DevicesApiRequestBuilder.deviceRewardsTimeline(deviceId: params.deviceId,
																	 page: params.page,
																	 pageSize: params.pageSize,
																	 fromDate: params.fromDate,
																	 toDate: params.toDate,
																	 timezone: params.timezone?.identifier)
		let urlRequest = try builder.asURLRequest()
		return ApiClient.shared.requestCodable(urlRequest, mockFileName: builder.mockFileName)
	}

	public func deviceRewardsSummary(deviceId: String) throws -> AnyPublisher<DataResponse<NetworkDeviceRewardsSummaryResponse, NetworkErrorResponse>, Never> {
		let builder =  DevicesApiRequestBuilder.deviceRewardsById(deviceId: deviceId)
		let urlRequest = try builder.asURLRequest()
		return ApiClient.shared.requestCodable(urlRequest, mockFileName: builder.mockFileName)
	}

	public func deviceRewardsDetails(deviceId: String, date: String) throws -> AnyPublisher<DataResponse<NetworkDeviceRewardDetailsResponse, NetworkErrorResponse>, Never> {
		let builder =  DevicesApiRequestBuilder.deviceRewardsDetailsById(deviceId: deviceId, date: date)
		let urlRequest = try builder.asURLRequest()
		return ApiClient.shared.requestCodable(urlRequest, mockFileName: builder.mockFileName)
	}

	public func deviceRewardsBoosts(deviceId: String, code: String) throws -> AnyPublisher<DataResponse<NetworkDeviceRewardBoostsResponse, NetworkErrorResponse>, Never> {
		let builder =  DevicesApiRequestBuilder.deviceRewardsBoosts(deviceId: deviceId, code: code)
		let urlRequest = try builder.asURLRequest()
		return ApiClient.shared.requestCodable(urlRequest, mockFileName: builder.mockFileName)
	}

    public init() {}
}
