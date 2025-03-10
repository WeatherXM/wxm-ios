//
//  DeviceInfoRepository.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 8/3/23.
//

import struct Alamofire.DataResponse
import Combine

public protocol DeviceInfoRepository {
    func getDeviceInfo(deviceId: String) throws -> AnyPublisher<DataResponse<NetworkDevicesInfoResponse, NetworkErrorResponse>, Never>
    func setFriendlyName(deviceId: String, name: String) throws -> AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never>
    func deleteFriendlyName(deviceId: String) throws -> AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never>
    func disclaimDevice(serialNumber: String) throws -> AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never>
    func rebootStation(device: DeviceDetails) -> AnyPublisher<RebootStationState, Never>
    func changeFrequency(device: DeviceDetails, frequency: Frequency) -> AnyPublisher<ChangeFrequencyState, Never>
	func getDevicePhotos(deviceId: String) throws -> AnyPublisher<DataResponse<[String], NetworkErrorResponse>, Never>
}

public enum RebootStationState: Sendable, Equatable {
    case connect
    case rebooting
    case failed(RebootError)
    case finished
}

public enum RebootError: Sendable, Equatable {
    case bluetooth(BluetoothState)
    case notInRange
    case connect
    case unknown
}

public enum ChangeFrequencyState: Sendable, Equatable {
    case connect
    case changing
    case failed(ChangeFrequencyError)
    case finished
}

public enum ChangeFrequencyError: Sendable, Equatable {
    case bluetooth(BluetoothState)
    case notInRange
    case connect
    case settingFrequency(String?)
    case unknown
}
