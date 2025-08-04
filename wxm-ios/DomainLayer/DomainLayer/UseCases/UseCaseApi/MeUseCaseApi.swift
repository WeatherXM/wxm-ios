//
//  MeUseCaseApi.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 1/4/25.
//

import Combine
import Alamofire
import Foundation
import Toolkit

public protocol MeUseCaseApi: Sendable {
	var userInfoPublisher: AnyPublisher<NetworkUserInfoResponse?, Never> { get }
	var userDevicesListChangedPublisher: NotificationCenter.Publisher { get }

	func shouldShowAddButtonIndication() async -> Bool
	func markAddButtonIndicationAsSeen()
	func getUserInfo() throws -> AnyPublisher<DataResponse<NetworkUserInfoResponse, NetworkErrorResponse>, Never>
	func getUserWallet() throws -> AnyPublisher<DataResponse<Wallet, NetworkErrorResponse>, Never>
	func saveUserWallet(address: String) throws -> AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never>
	func getDevices() throws -> AnyPublisher<Result<[DeviceDetails], NetworkErrorResponse>, Never>
	func getCachedOwnedDevices() -> [DeviceDetails]?
	func getOwnedDevices() throws -> AnyPublisher<Result<[DeviceDetails], NetworkErrorResponse>, Never>
	func claimDevice(claimDeviceBody: ClaimDeviceBody) throws -> AnyPublisher<Result<DeviceDetails, NetworkErrorResponse>, Never>
	func setFrequency(_ serialNumber: String, frequency: Frequency) async throws -> NetworkErrorResponse?
	func getFirmwares(testSearch: String) throws -> AnyPublisher<DataResponse<[NetworkFirmwareResponse], NetworkErrorResponse>, Never>
	func getUserDeviceById(deviceId: String) throws -> AnyPublisher<Result<DeviceDetails, NetworkErrorResponse>, Never>
	func getUserDeviceForecastById(deviceId: String, fromDate: String, toDate: String, exclude: String) throws -> AnyPublisher<DataResponse<[NetworkDeviceForecastResponse], NetworkErrorResponse>, Never>
	func getUserDeviceRewards(deviceId: String, mode: DeviceRewardsMode) throws -> AnyPublisher<DataResponse<NetworkDeviceRewardsResponse, NetworkErrorResponse>, Never>
	func getUserDevicesRewards(mode: DeviceRewardsMode) throws -> AnyPublisher<DataResponse<NetworkDevicesRewardsResponse, NetworkErrorResponse>, Never>
	func deleteAccount() throws -> AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never>
	func followStation(deviceId: String) async throws -> Result<EmptyEntity, NetworkErrorResponse>
	func unfollowStation(deviceId: String) async throws -> Result<EmptyEntity, NetworkErrorResponse>
	func getDeviceFollowState(deviceId: String) async throws -> Result<UserDeviceFollowState?, NetworkErrorResponse>
	func getFiltersPublisher() -> AnyPublisher<FilterValues, Never>
	func hasOwnedDevices() async -> Bool
	func getUserRewards(wallet: String) throws -> AnyPublisher<DataResponse<NetworkUserRewardsResponse, NetworkErrorResponse>, Never>
	func setDeviceLocationById(deviceId: String, lat: Double, lon: Double) throws -> AnyPublisher<Result<DeviceDetails, NetworkErrorResponse>, Never>
	func lastNotificationAlertSent(for deviceId: String, alert: StationNotificationsTypes) -> Date?
	func notificationAlertSent(for deviceId: String, alert: StationNotificationsTypes)
}
