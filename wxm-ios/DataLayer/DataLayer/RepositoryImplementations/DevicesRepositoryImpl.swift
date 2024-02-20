//
//  DevicesRepositoryImpl.swift
//  DataLayer
//
//  Created by Danae Kikue Dimou on 18/5/22.
//

import Alamofire
import Combine
import DomainLayer
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

    public func deviceTokenTransactions(deviceId: String, page: Int, pageSize: Int?, timezone: String, fromDate: String, toDate: String?) throws -> AnyPublisher<DataResponse<NetworkDeviceIDTokensTransactionsResponse, NetworkErrorResponse>, Never> {
		let builder = DevicesApiRequestBuilder.deviceTokenTransactions(deviceId: deviceId, page: page, pageSize: pageSize, timezone: timezone, fromDate: fromDate, toDate: toDate)
        let urlRequest = try builder.asURLRequest()
		return ApiClient.shared.requestCodable(urlRequest, mockFileName: builder.mockFileName)
    }

    public func deviceTokens(deviceId: String) async throws -> Result<NetworkDeviceIDTokensTransactionsResponse, NetworkErrorResponse> {
        let fromDate = Calendar.current.date(byAdding: .day, value: -30, to: Date())!.getFormattedDate(format: .onlyDate)
        let toDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())!.getFormattedDate(format: .onlyDate)
        return try await withCheckedThrowingContinuation { continuation in

            do {
                let pageSizeTransactions = try deviceTokenTransactions(deviceId: deviceId,
                                                                       page: 0,
                                                                       pageSize: 1,
                                                                       timezone: TimeZone.current.identifier,
                                                                       fromDate: fromDate,
                                                                       toDate: toDate)
                pageSizeTransactions.sink { response in
                    if let error = response.error {
                        continuation.resume(returning: .failure(error))
                        return
                    }

                    let totalPages = response.value?.totalPages ?? 0
                    do {
                        let totalTransactions = try deviceTokenTransactions(deviceId: deviceId,
                                                                            page: 0,
                                                                            pageSize: totalPages,
                                                                            timezone: TimeZone.current.identifier,
                                                                            fromDate: fromDate,
                                                                            toDate: toDate)
                        totalTransactions.sink { response in
                            if let error = response.error {
                                continuation.resume(returning: .failure(error))
                                return
                            }

                            continuation.resume(returning: .success(response.value!))
                        }
                        .store(in: &cancellables.cancellableSet)
                    } catch {
                        continuation.resume(throwing: error)
                    }

                }
                .store(in: &cancellables.cancellableSet)

            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

	#warning("TODO: - Remove once the reward summary is implemented")
	public func deviceRewards(deviceId: String) throws -> AnyPublisher<DataResponse<NetworkDeviceTokensResponse, NetworkErrorResponse>, Never> {
		let builder =  DevicesApiRequestBuilder.deviceRewardsById(deviceId: deviceId)
		let urlRequest = try builder.asURLRequest()
		return ApiClient.shared.requestCodable(urlRequest, mockFileName: builder.mockFileName)
	}

	public func deviceRewardsSummary(deviceId: String) throws -> AnyPublisher<DataResponse<NetworkDeviceRewardsSummary, NetworkErrorResponse>, Never> {
		let builder =  DevicesApiRequestBuilder.deviceRewardsById(deviceId: deviceId)
		let urlRequest = try builder.asURLRequest()
		return ApiClient.shared.requestCodable(urlRequest, mockFileName: builder.mockFileName)
	}

    public init() {}
}
