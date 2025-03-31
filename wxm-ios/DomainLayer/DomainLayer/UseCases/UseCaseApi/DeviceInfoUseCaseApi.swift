//
//  Untitled.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 31/3/25.
//

import Combine
import Alamofire

public protocol DeviceInfoUseCaseApi: Sendable {
	func getDeviceInfo(deviceId: String) throws -> AnyPublisher<DataResponse<NetworkDevicesInfoResponse, NetworkErrorResponse>, Never>
	func setFriendlyName(deviceId: String, name: String) throws -> AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never>
	func deleteFriendlyName(deviceId: String) throws -> AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never>
	func disclaimDevice(serialNumber: String) throws -> AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never>
	func rebootStation(device: DeviceDetails) -> AnyPublisher<RebootStationState, Never>
	func changeFrequency(device: DeviceDetails, frequency: Frequency) -> AnyPublisher<ChangeFrequencyState, Never>
	func getDevicePhotos(deviceId: String) async throws -> Result<[NetworkDevicePhotosResponse], NetworkErrorResponse>
}
