//
//  MockMeUseCase.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 1/4/25.
//

import Foundation
@testable import WeatherXM
import DomainLayer
import Combine
import Alamofire

final class MockMeUseCase: MeUseCaseApi {
	nonisolated(unsafe) var addButtonIndicationSeen: Bool = false

	var userInfoPublisher: AnyPublisher<NetworkUserInfoResponse?, Never> {
		Just(nil).eraseToAnyPublisher()
	}

	var userDevicesListChangedPublisher: NotificationCenter.Publisher {
		NotificationCenter.default.publisher(for: Notification.Name("MockMeUseCase.userDevicesListChanged"))
	}

	func shouldShowAddButtonIndication() async -> Bool {
		true
	}

	func markAddButtonIndicationAsSeen() {
		addButtonIndicationSeen = true
	}

	func getUserInfo() throws -> AnyPublisher<DataResponse<NetworkUserInfoResponse, NetworkErrorResponse>, Never> {
		let user = NetworkUserInfoResponse()
		let response = DataResponse<NetworkUserInfoResponse, NetworkErrorResponse>(request: nil,
																				   response: nil,
																				   data: nil,
																				   metrics: nil,
																				   serializationDuration: 0,
																				   result: .success(user))
		return Just(response).eraseToAnyPublisher()
	}

	func getUserWallet() throws -> AnyPublisher<DataResponse<Wallet, NetworkErrorResponse>, Never> {
		let wallet = Wallet()
		let response = DataResponse<Wallet, NetworkErrorResponse>(request: nil,
																  response: nil,
																  data: nil,
																  metrics: nil,
																  serializationDuration: 0,
																  result: .success(wallet))
		return Just(response).eraseToAnyPublisher()
	}

	func saveUserWallet(address: String) throws -> AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never> {
		let emptyEntity = EmptyEntity.emptyValue()
		let response = DataResponse<EmptyEntity, NetworkErrorResponse>(request: nil,
																	   response: nil,
																	   data: nil,
																	   metrics: nil,
																	   serializationDuration: 0,
																	   result: .success(emptyEntity))
		return Just(response).eraseToAnyPublisher()
	}

	func getDevices() throws -> AnyPublisher<Result<[DeviceDetails], NetworkErrorResponse>, Never> {
		let device = DeviceDetails.mockDevice
		return Just(.success([device])).eraseToAnyPublisher()
	}

	func claimDevice(claimDeviceBody: ClaimDeviceBody) throws -> AnyPublisher<Result<DeviceDetails, NetworkErrorResponse>, Never> {
		let device = DeviceDetails.mockDevice
		return Just(.success(device)).eraseToAnyPublisher()
	}

	func setFrequency(_ serialNumber: String, frequency: Frequency) async throws -> NetworkErrorResponse? {
		nil
	}

	func getFirmwares(testSearch: String) throws -> AnyPublisher<DataResponse<[NetworkFirmwareResponse], NetworkErrorResponse>, Never> {
		let firmware = NetworkFirmwareResponse()
		let response = DataResponse<[NetworkFirmwareResponse], NetworkErrorResponse>(request: nil,
																					 response: nil,
																					 data: nil,
																					 metrics: nil,
																					 serializationDuration: 0,
																					 result: .success([firmware]))
		return Just(response).eraseToAnyPublisher()
	}

	func getUserDeviceById(deviceId: String) throws -> AnyPublisher<Result<DeviceDetails, NetworkErrorResponse>, Never> {
		let device = DeviceDetails.mockDevice
		return Just(.success(device)).eraseToAnyPublisher()
	}

	func getUserDeviceForecastById(deviceId: String, fromDate: String, toDate: String, exclude: String) throws -> AnyPublisher<DataResponse<[NetworkDeviceForecastResponse], NetworkErrorResponse>, Never> {
		let forecast = [NetworkDeviceForecastResponse]()
		let response = DataResponse<[NetworkDeviceForecastResponse], NetworkErrorResponse>(request: nil,
																						   response: nil,
																						   data: nil,
																						   metrics: nil,
																						   serializationDuration: 0,
																						   result: .success(forecast))
		return Just(response).eraseToAnyPublisher()
	}

	func getUserDeviceRewards(deviceId: String, mode: DeviceRewardsMode) throws -> AnyPublisher<DataResponse<NetworkDeviceRewardsResponse, NetworkErrorResponse>, Never> {
		let rewardResponse = NetworkDeviceRewardsResponse(total: 0.0, data: nil, details: nil)
		let response = DataResponse<NetworkDeviceRewardsResponse, NetworkErrorResponse>(request: nil,
																						response: nil,
																						data: nil,
																						metrics: nil,
																						serializationDuration: 0,
																						result: .success(rewardResponse))
		return Just(response).eraseToAnyPublisher()
	}

	func getUserDevicesRewards(mode: DeviceRewardsMode) throws -> AnyPublisher<DataResponse<NetworkDevicesRewardsResponse, NetworkErrorResponse>, Never> {
		let rewardResponse = NetworkDevicesRewardsResponse(total: 0.0, data: nil)
		let response = DataResponse<NetworkDevicesRewardsResponse, NetworkErrorResponse>(request: nil,
																						response: nil,
																						data: nil,
																						metrics: nil,
																						serializationDuration: 0,
																						result: .success(rewardResponse))
		return Just(response).eraseToAnyPublisher()
	}

	func deleteAccount() throws -> AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never> {
		let emptyEntity = EmptyEntity.emptyValue()
		let response = DataResponse<EmptyEntity, NetworkErrorResponse>(request: nil,
																	   response: nil,
																	   data: nil,
																	   metrics: nil,
																	   serializationDuration: 0,
																	   result: .success(emptyEntity))
		return Just(response).eraseToAnyPublisher()
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

	func getFiltersPublisher() -> AnyPublisher<FilterValues, Never> {
		Just(FilterValues(sortBy: .dateAdded,
						  filter: .all,
						  groupBy: .noGroup)).eraseToAnyPublisher()
	}

	func hasOwnedDevices() async -> Bool {
		false
	}

	func getUserRewards(wallet: String) throws -> AnyPublisher<DataResponse<NetworkUserRewardsResponse, NetworkErrorResponse>, Never> {
		let rewardsResponse = NetworkUserRewardsResponse(proof: nil,
														 cumulativeAmount: nil,
														 cycle: nil,
														 available: nil,
														 totalClaimed: nil)
		let response = DataResponse<NetworkUserRewardsResponse, NetworkErrorResponse>(request: nil,
																					  response: nil,
																					  data: nil,
																					  metrics: nil,
																					  serializationDuration: 0,
																					  result: .success(rewardsResponse))
		return Just(response).eraseToAnyPublisher()
	}

	func setDeviceLocationById(deviceId: String, lat: Double, lon: Double) throws -> AnyPublisher<Result<DeviceDetails, NetworkErrorResponse>, Never> {
		let device = DeviceDetails.mockDevice
		return Just(.success(device)).eraseToAnyPublisher()
	}

	func shouldSendNotificationAlert(for deviceId: String, alert: StationAlert) -> Bool {
		true
	}

	func notificationAlertSent(for deviceId: String, alert: StationAlert) {
		
	}
}
