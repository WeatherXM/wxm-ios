//
//  RewardsUseCase.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 1/8/23.
//

import Foundation
import Combine
import Alamofire
import Toolkit

public struct RewardsUseCase {
    private let meRepository: MeRepository
    private let devicesRepository: DevicesRepository
    private let keychainRepository: KeychainRepository
    private let cancellables: CancellableWrapper = .init()

    public init(meRepository: MeRepository, devicesRepository: DevicesRepository, keychainRepository: KeychainRepository) {
        self.meRepository = meRepository
        self.devicesRepository = devicesRepository
        self.keychainRepository = keychainRepository
    }

    public func getDeviceTokenTransactions(deviceId: String,
                                    page: Int,
                                    pageSize: Int, timezone: String,
                                    fromDate: String,
                                    toDate: String) async throws -> Result<NetworkDeviceIDTokensTransactionsResponse, NetworkErrorResponse> {
        let isUserDeviceResult = try await meRepository.getDeviceFollowState(deviceId: deviceId)
        switch isUserDeviceResult {
            case .success(let isUserDevice):
                if let isUserDevice {
                    return try await getUserDeviceTokensTransactions(deviceId: deviceId,
                                                                     page: page,
                                                                     pageSize: pageSize,
                                                                     timezone: timezone,
                                                                     fromDate: fromDate,
                                                                     toDate: toDate)
                }

                return try await getPublicDeviceTokenTransactions(deviceId: deviceId,
                                                                  page: page,
                                                                  pageSize: pageSize,
                                                                  timezone: timezone,
                                                                  fromDate: fromDate,
                                                                  toDate: toDate)
            case .failure(let error):
                return .failure(error)
        }
    }

	public func getDeviceRewards(deviceId: String) async throws -> Result<NetworkDeviceTokensResponse, NetworkErrorResponse> {
		let rewardsPublisher = try devicesRepository.deviceRewards(deviceId: deviceId)
		return await withUnsafeContinuation { continuation in
			rewardsPublisher.sink { response in
				if let error = response.error {
					continuation.resume(returning: .failure(error))
				} else {
					continuation.resume(returning: .success(response.value!))
				}
			}.store(in: &cancellables.cancellableSet)
		}
	}
}

private extension RewardsUseCase {

    func getUserDeviceTokensTransactions(deviceId: String,
                                         page: Int,
                                         pageSize: Int, timezone: String,
                                         fromDate: String,
                                         toDate: String) async throws -> Result<NetworkDeviceIDTokensTransactionsResponse, NetworkErrorResponse> {
        let userDeviceTransactions = try meRepository.getUserDeviceTokensTransactionsById(deviceId: deviceId,
                                                                                          page: page,
                                                                                          pageSize: pageSize,
                                                                                          timezone: timezone,
                                                                                          fromDate: fromDate,
                                                                                          toDate: toDate)
        return await withCheckedContinuation { continuation in
            userDeviceTransactions.sink { response in
                if let error = response.error {
                    continuation.resume(returning: .failure(error))
                } else {
                    continuation.resume(returning: .success(response.value!))
                }
            }
            .store(in: &cancellables.cancellableSet)
        }
    }

    func getPublicDeviceTokenTransactions(deviceId: String,
                                          page: Int,
                                          pageSize: Int, timezone: String,
                                          fromDate: String,
                                          toDate: String) async throws -> Result<NetworkDeviceIDTokensTransactionsResponse, NetworkErrorResponse> {
        let deviceTransactions = try devicesRepository.deviceTokenTransactions(deviceId: deviceId,
                                                                               page: page,
                                                                               pageSize: pageSize,
                                                                               timezone: timezone,
                                                                               fromDate: fromDate,
                                                                               toDate: toDate)

        return await withCheckedContinuation { continuation in
            deviceTransactions.sink { response in
                if let error = response.error {
                    continuation.resume(returning: .failure(error))
                } else {
                    continuation.resume(returning: .success(response.value!))
                }
            }
            .store(in: &cancellables.cancellableSet)
        }
    }
}
