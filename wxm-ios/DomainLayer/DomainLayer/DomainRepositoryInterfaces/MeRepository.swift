//
//  MeRepository.swift
//  DomainLayer
//
//  Created by Hristos Condrea on 17/5/22.
//

import Alamofire
import Combine
import Foundation

public enum HistoryExclude: String {
    case hourly
    case daily
}

public struct UserDeviceFollowState: Hashable, Codable {
    public let deviceId: String
    public let relation: DeviceRelation

    public init(deviceId: String, relation: DeviceRelation) {
        self.deviceId = deviceId
        self.relation = relation
    }
}

public protocol MeRepository {
    var userDevicesChangedNotificationPublisher: NotificationCenter.Publisher { get }
	var userInfoPublisher: AnyPublisher<NetworkUserInfoResponse?, Never> { get }
    func getUser() throws -> AnyPublisher<DataResponse<NetworkUserInfoResponse, NetworkErrorResponse>, Never>
    func getUserWallet() throws -> AnyPublisher<DataResponse<Wallet, NetworkErrorResponse>, Never>
    func saveUserWallet(address: String) throws -> AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never>
	func getDevices(useCache: Bool) throws -> AnyPublisher<DataResponse<[NetworkDevicesResponse], NetworkErrorResponse>, Never>
	func getCachedDevices() -> [NetworkDevicesResponse]?
    func claimDevice(claimDeviceBody: ClaimDeviceBody) throws -> AnyPublisher<DataResponse<NetworkDevicesResponse, NetworkErrorResponse>, Never>
    func getFirmwares(testSearch: String) throws -> AnyPublisher<DataResponse<[NetworkFirmwareResponse], NetworkErrorResponse>, Never>
    func getUserDeviceById(deviceId: String) throws -> AnyPublisher<DataResponse<NetworkDevicesResponse, NetworkErrorResponse>, Never>
    func getUserDeviceHourlyHistoryById(deviceId: String, date: Date, force: Bool) throws -> AnyPublisher<DataResponse<[NetworkDeviceHistoryResponse], NetworkErrorResponse>, Never>
    func getUserDeviceForecastById(deviceId: String, fromDate: String, toDate: String, exclude: String) throws -> AnyPublisher<DataResponse<[NetworkDeviceForecastResponse], NetworkErrorResponse>, Never>
    func deleteAccount() throws -> AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never>
    func followStation(deviceId: String) throws -> AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never>
    func unfollowStation(deviceId: String) throws -> AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never>
    func getDeviceFollowState(deviceId: String) async throws -> Result<UserDeviceFollowState?, NetworkErrorResponse>
	func getUserDevicesFollowStates() async throws -> Result<[UserDeviceFollowState]?, NetworkErrorResponse>
	func setDeviceLocationById(deviceId: String, lat: Double, lon: Double) throws -> AnyPublisher<DataResponse<NetworkDevicesResponse, NetworkErrorResponse>, Never>
	func setNotificationsFcmToken(installationId: String, token: String) throws -> AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never>
}
