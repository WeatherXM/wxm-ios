//
//  WidgetUseCaseApi.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 1/4/25.
//

import Foundation

public protocol WidgetUseCaseApi: Sendable {
	var isUserLoggedIn: Bool { get }

	func getCachedDevices() -> [DeviceDetails]?
	func getDevices(useCache: Bool) async throws -> Result<[DeviceDetails], NetworkErrorResponse>
	func getDeviceFollowState(deviceId: String) async throws -> Result<UserDeviceFollowState?, NetworkErrorResponse>
}
