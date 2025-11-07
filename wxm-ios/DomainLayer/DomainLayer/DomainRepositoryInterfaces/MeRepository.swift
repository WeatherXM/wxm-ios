//
//  MeRepository.swift
//  DomainLayer
//
//  Created by Hristos Condrea on 17/5/22.
//

import Alamofire
import Combine
import Foundation
import StoreKit

public enum HistoryExclude: String {
    case hourly
    case daily
}

public enum DeviceRewardsMode: String, CaseIterable, Sendable {
	// Temporary disable the year mode.
	// Once we want it back, just remove the `allCases` implementation below
	public static var allCases: [DeviceRewardsMode] {
		[.week, .month]
	}
	case week
	case month
	case year
}

public struct UserDeviceFollowState: Hashable, Codable, Sendable {
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
	func getOwnedDevices() throws -> AnyPublisher<DataResponse<[NetworkDevicesResponse], NetworkErrorResponse>, Never>
	func getDevices(useCache: Bool) throws -> AnyPublisher<DataResponse<[NetworkDevicesResponse], NetworkErrorResponse>, Never>
	func getCachedDevices() -> [NetworkDevicesResponse]?
    func claimDevice(claimDeviceBody: ClaimDeviceBody) throws -> AnyPublisher<DataResponse<NetworkDevicesResponse, NetworkErrorResponse>, Never>
	func setFrequency(serialNumber: String, frequency: String) throws -> AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never>
    func getFirmwares(testSearch: String) throws -> AnyPublisher<DataResponse<[NetworkFirmwareResponse], NetworkErrorResponse>, Never>
    func getUserDeviceById(deviceId: String) throws -> AnyPublisher<DataResponse<NetworkDevicesResponse, NetworkErrorResponse>, Never>
    func getUserDeviceHourlyHistoryById(deviceId: String,
										date: Date,
										force: Bool) throws -> AnyPublisher<DataResponse<[NetworkDeviceHistoryResponse], NetworkErrorResponse>, Never>
    func getUserDeviceForecastById(deviceId: String,
								   fromDate: String,
								   toDate: String,
								   exclude: String) throws -> AnyPublisher<DataResponse<[NetworkDeviceForecastResponse], NetworkErrorResponse>, Never>
	func getUserDeviceRewardAnalytics(deviceId: String, mode: DeviceRewardsMode) throws -> AnyPublisher<DataResponse<NetworkDeviceRewardsResponse, NetworkErrorResponse>, Never>
	func getUserDevicesRewardAnalytics(mode: DeviceRewardsMode) throws -> AnyPublisher<DataResponse<NetworkDevicesRewardsResponse, NetworkErrorResponse>, Never>
    func deleteAccount() throws -> AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never>
    func followStation(deviceId: String) throws -> AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never>
    func unfollowStation(deviceId: String) throws -> AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never>
    func getDeviceFollowState(deviceId: String) async throws -> Result<UserDeviceFollowState?, NetworkErrorResponse>
	func getUserDevicesFollowStates() async throws -> Result<[UserDeviceFollowState]?, NetworkErrorResponse>
	func setDeviceLocationById(deviceId: String, lat: Double, lon: Double) throws -> AnyPublisher<DataResponse<NetworkDevicesResponse, NetworkErrorResponse>, Never>
	func setNotificationsFcmToken(installationId: String, token: String) throws -> AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never>
	func getDeviceSupport(deviceName: String) throws -> AnyPublisher<DataResponse<NetworkDeviceSupportResponse, NetworkErrorResponse>, Never>
	func getSubscriptionProducts(identifiers: [String]) async throws -> [Product]
}
