//
//  MockExplorerUseCase.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 2/4/25.
//

import DomainLayer
import Combine
import CoreLocation
import Foundation
import Toolkit

struct MockExplorerUseCase: ExplorerUseCaseApi {
	var userDevicesListChangedPublisher: NotificationCenter.Publisher {
		NotificationCenter.default.publisher(for: Notification.Name("MockExplorerUseCase.userDevicesListChangedPublisher"))
	}

	var userLocationAuthorizationStatus: WXMLocationManager.Status {
		.authorized
	}

	func getUserLocation() async -> Result<CLLocationCoordinate2D, ExplorerLocationError> {
		.success(CLLocationCoordinate2D())
	}
	
	func getSuggestedDeviceLocation() -> CLLocationCoordinate2D? {
		nil
	}
	
	func getCell(cellIndex: String) async throws -> Result<PublicHex?, NetworkErrorResponse> {
		.success(nil)
	}
	
	func getPublicHexes(completion: @escaping (Result<ExplorerData, PublicHexError>) -> Void) {
		completion(.success(ExplorerData()))
	}
	
	func getPublicDevicesOfHexIndex(hexIndex: String, hexCoordinates: CLLocationCoordinate2D?, completion: @escaping @Sendable (Result<[DeviceDetails], PublicHexError>) -> Void) {
		completion(.success([]))
	}
	
	func getPublicDevice(hexIndex: String, deviceId: String, completion: @escaping (Result<DeviceDetails, PublicHexError>) -> Void) {
		completion(.success(DeviceDetails.emptyDeviceDetails))
	}
	
	func followStation(deviceId: String) async throws -> Result<EmptyEntity, NetworkErrorResponse> {
		.success(EmptyEntity.emptyValue())
	}
	
	func unfollowStation(deviceId: String) async throws -> Result<EmptyEntity, NetworkErrorResponse> {
		.success(EmptyEntity.emptyValue())
	}
	
	func getDeviceFollowState(deviceId: String) async throws -> Result<UserDeviceFollowState?, NetworkErrorResponse> {
		.success(nil)
	}
}
