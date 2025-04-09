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

public struct RewardsUseCase: RewardsUseCaseApi {
	nonisolated(unsafe) private let devicesRepository: DevicesRepository

    public init(devicesRepository: DevicesRepository) {
        self.devicesRepository = devicesRepository
    }

	public func getDeviceRewardsSummary(deviceId: String) async throws -> Result<NetworkDeviceRewardsSummaryResponse, NetworkErrorResponse> {
		let rewardsPublisher = try await devicesRepository.deviceRewardsSummary(deviceId: deviceId).toAsync().result
		return rewardsPublisher
	}
}
