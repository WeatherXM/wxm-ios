//
//  DeviceDetailsUseCase.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 31/3/25.
//

import CoreLocation

public protocol DeviceDetailsUseCaseApi: Sendable {
	func getDeviceDetailsById(deviceId: String, cellIndex: String?) async throws -> Result<DeviceDetails, NetworkErrorResponse>
	func followStation(deviceId: String) async throws ->  Result<EmptyEntity, NetworkErrorResponse>
	func unfollowStation(deviceId: String) async throws ->  Result<EmptyEntity, NetworkErrorResponse>
	func resolveAddress(location: CLLocationCoordinate2D) async throws -> String
	func getDeviceFollowState(deviceId: String) async throws -> Result<UserDeviceFollowState?, NetworkErrorResponse>
}

