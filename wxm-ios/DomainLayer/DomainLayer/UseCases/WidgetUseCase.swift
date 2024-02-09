//
//  WidgetUseCase.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 29/9/23.
//

import Foundation
import Combine
import Toolkit

public struct WidgetUseCase {
	private let meRepository: MeRepository
	private let keychainRepository: KeychainRepository
	private let cancellableWrapper: CancellableWrapper = .init()
	
	public init(meRepository: MeRepository, keychainRepository: KeychainRepository) {
		self.meRepository = meRepository
		self.keychainRepository = keychainRepository
	}
	
	public var isUserLoggedIn: Bool {
		keychainRepository.isUserLoggedIn()
	}
	
	/// Get the local persisted user devices
	/// - Returns: An array of the local persisted user devices
	public func getCachedDevices() -> [DeviceDetails]? {
		meRepository.getCachedDevices()?.map { $0.toDeviceDetails }
	}

	public func getDevices(useCache: Bool = true) async throws -> Result<[DeviceDetails], NetworkErrorResponse> {
		let userDevices = try meRepository.getDevices(useCache: useCache)
		let publisher = userDevices.convertedToDeviceDetailsResultPublisher
		return await withUnsafeContinuation { continuation in
			publisher.sink { result in
				continuation.resume(returning: result)
			}
			.storeThreadSafe(in: &cancellableWrapper.cancellableSet)
		}
	}

	public func getDeviceFollowState(deviceId: String) async throws -> Result<UserDeviceFollowState?, NetworkErrorResponse> {
		try await meRepository.getDeviceFollowState(deviceId: deviceId)
	}
}
