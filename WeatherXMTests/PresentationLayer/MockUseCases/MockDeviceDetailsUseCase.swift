//
//  MockDeviceDetailsUseCase.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 1/4/25.
//

import Foundation
@testable import WeatherXM
import DomainLayer
import CoreLocation

struct MockDeviceDetailsUseCase: DeviceDetailsUseCaseApi {
	var hasNotificationsPromptBeenShown: Bool {
		true
	}

	func notificationsPromptShown() {

	}
	
	func getDeviceDetailsById(deviceId: String, cellIndex: String?) async throws -> Result<DeviceDetails, NetworkErrorResponse> {
		.success(DeviceDetails.mockDevice)
	}
	
	func followStation(deviceId: String) async throws -> Result<EmptyEntity, NetworkErrorResponse> {
		.success(EmptyEntity.emptyValue())
	}
	
	func unfollowStation(deviceId: String) async throws -> Result<EmptyEntity, NetworkErrorResponse> {
		.success(EmptyEntity.emptyValue())
	}
	
	func resolveAddress(location: CLLocationCoordinate2D) async throws -> String {
		try await MockGeocoder().resolveAddressLocation(location)
	}
	
	func getDeviceFollowState(deviceId: String) async throws -> Result<UserDeviceFollowState?, NetworkErrorResponse> {
		.success(UserDeviceFollowState(deviceId: deviceId,
									   relation: .followed))
	}

}
