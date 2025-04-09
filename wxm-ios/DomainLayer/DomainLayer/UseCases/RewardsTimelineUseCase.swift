//
//  RewardsTimelineUseCase.swift
//  DomainLayer
//
//  Created by Lampros Zouloumis on 13/9/22.
//

import Combine
import Toolkit

public class RewardsTimelineUseCase: @unchecked Sendable, RewardsTimelineUseCaseApi {
	private let repository: DevicesRepository
	private let meRepository: MeRepository
	private var cancellableSet: Set<AnyCancellable> = []
	
	public init(repository: DevicesRepository, meRepository: MeRepository) {
		self.repository = repository
		self.meRepository = meRepository
	}
	
	public func getTimeline(deviceId: String,
							page: Int,
							fromDate: String,
							toDate: String,
							timezone: TimeZone? = .UTCTimezone) async throws -> Result<NetworkDeviceRewardsTimelineResponse?, NetworkErrorResponse> {
		let publisher = try repository.deviceRewardsTimeline(params: .init(deviceId: deviceId,
																		   page: page,
																		   pageSize: nil,
																		   fromDate: fromDate,
																		   toDate: toDate,
																		   timezone: timezone))
		return await withUnsafeContinuation { continuation in
			publisher.sink { response in
				if let error = response.error {
					continuation.resume(returning: .failure(error))
				} else {
					continuation.resume(returning: .success(response.value))
				}
			}.store(in: &cancellableSet)
		}
	}
	
	public func getFollowState(deviceId: String) async throws -> Result<UserDeviceFollowState?, NetworkErrorResponse> {
		try await meRepository.getDeviceFollowState(deviceId: deviceId)
	}

	public func getRewardDetails(deviceId: String, date: String) async throws -> Result<NetworkDeviceRewardDetailsResponse?, NetworkErrorResponse> {
		let publisher = try repository.deviceRewardsDetails(deviceId: deviceId, date: date)

		return await withUnsafeContinuation { continuation in
			publisher.sink { response in

				if let error = response.error {
					continuation.resume(returning: .failure(error))
				} else {
					continuation.resume(returning: .success(response.value))
				}
			}.store(in: &cancellableSet)
		}
	}

	public func getRewardBoosts(deviceId: String, code: String) async throws -> Result<NetworkDeviceRewardBoostsResponse?, NetworkErrorResponse> {
		let publisher = try repository.deviceRewardsBoosts(deviceId: deviceId, code: code)

		return await withUnsafeContinuation { continuation in
			publisher.sink { response in

				if let error = response.error {
					continuation.resume(returning: .failure(error))
				} else {
					continuation.resume(returning: .success(response.value))
				}
			}.store(in: &cancellableSet)
		}
	}
}
