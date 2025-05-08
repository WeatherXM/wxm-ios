//
//  ExplorerUseCaseApi.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 1/4/25.
//

import Combine
import CoreLocation
import Foundation
import Toolkit

public let EXPLORER_DEVICE_COUNT_KEY = "device_count"
public let EXPLORER_ACTIVE_DEVICE_COUNT_KEY = "active_device_count"

public protocol ExplorerUseCaseApi: Sendable {
	var userDevicesListChangedPublisher: NotificationCenter.Publisher { get }
	var userLocationAuthorizationStatus: WXMLocationManager.Status { get }

	func getUserLocation() async -> Result<CLLocationCoordinate2D, ExplorerLocationError>
	func getSuggestedDeviceLocation() -> CLLocationCoordinate2D?
	func getCell(cellIndex: String) async throws -> Result<PublicHex?, NetworkErrorResponse>
	func getPublicHexes(completion: @escaping (Result<ExplorerData, PublicHexError>) -> Void)
	func getPublicDevicesOfHexIndex(hexIndex: String, hexCoordinates: CLLocationCoordinate2D?, completion: @escaping @Sendable (Result<[DeviceDetails], PublicHexError>) -> Void)
	func getPublicDevice(hexIndex: String, deviceId: String, completion: @escaping (Result<DeviceDetails, PublicHexError>) -> Void)
	func followStation(deviceId: String) async throws -> Result<EmptyEntity, NetworkErrorResponse>
	func unfollowStation(deviceId: String) async throws -> Result<EmptyEntity, NetworkErrorResponse>
	func getDeviceFollowState(deviceId: String) async throws -> Result<UserDeviceFollowState?, NetworkErrorResponse>
}
