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

	public func getDeviceRewardsSummary(deviceId: String) async throws -> Result<NetworkDeviceRewardsSummaryResponse, NetworkErrorResponse> {
		let rewardsPublisher = try devicesRepository.deviceRewardsSummary(deviceId: deviceId)
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
