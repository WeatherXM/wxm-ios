//
//  MockMeRepositoryImpl.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 6/3/25.
//

import Foundation
@testable import DomainLayer
import Combine
import Alamofire

class MockMeRepositoryImpl {
	private var userInfoSubject = CurrentValueSubject<NetworkUserInfoResponse?, Never>(nil)

}

extension MockMeRepositoryImpl {
	enum Constants: String {
		case followedDeviceId
		case ownedDeviceId
	}
}

extension MockMeRepositoryImpl: MeRepository {
	var userDevicesChangedNotificationPublisher: NotificationCenter.Publisher {
		NotificationCenter.default.publisher(for: Notification.Name("MockMeRepositoryImpl.userIsLoggedInChanged"))
	}
	
	var userInfoPublisher: AnyPublisher<NetworkUserInfoResponse?, Never> {
		userInfoSubject.eraseToAnyPublisher()
	}
	
	func getUser() throws -> AnyPublisher<DataResponse<NetworkUserInfoResponse, NetworkErrorResponse>, Never> {
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
		let emptyEntity = EmptyEntity()
		let response = DataResponse<EmptyEntity, NetworkErrorResponse>(request: nil,
																	   response: nil,
																	   data: nil,
																	   metrics: nil,
																	   serializationDuration: 0,
																	   result: .success(emptyEntity))
		return Just(response).eraseToAnyPublisher()
	}
	
	func getDevices(useCache: Bool) throws -> AnyPublisher<DataResponse<[NetworkDevicesResponse], NetworkErrorResponse>, Never> {
		let device = NetworkDevicesResponse()
		let response = DataResponse<[NetworkDevicesResponse], NetworkErrorResponse>(request: nil,
																					response: nil,
																					data: nil,
																					metrics: nil,
																					serializationDuration: 0,
																					result: .success([device]))
		return Just(response).eraseToAnyPublisher()
	}
	
	func getCachedDevices() -> [NetworkDevicesResponse]? {
		[NetworkDevicesResponse()]
	}
	
	func claimDevice(claimDeviceBody: ClaimDeviceBody) throws -> AnyPublisher<DataResponse<NetworkDevicesResponse, NetworkErrorResponse>, Never> {
		let device = NetworkDevicesResponse()
		let response = DataResponse<NetworkDevicesResponse, NetworkErrorResponse>(request: nil,
																				  response: nil,
																				  data: nil,
																				  metrics: nil,
																				  serializationDuration: 0,
																				  result: .success(device))
		return Just(response).eraseToAnyPublisher()
	}

	func setFrequency(serialNumber: String, frequency: String) throws -> AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never> {
		let emptyEntity = EmptyEntity()
		let response = DataResponse<EmptyEntity, NetworkErrorResponse>(request: nil,
																	   response: nil,
																	   data: nil,
																	   metrics: nil,
																	   serializationDuration: 0,
																	   result: .success(emptyEntity))
		return Just(response).eraseToAnyPublisher()
	}
	
	func getFirmwares(testSearch: String) throws -> AnyPublisher<DataResponse<[NetworkFirmwareResponse], NetworkErrorResponse>, Never> {
		let firmwareResponses: [NetworkFirmwareResponse] = []
		let response = DataResponse<[NetworkFirmwareResponse], NetworkErrorResponse>(request: nil,
																				  response: nil,
																				  data: nil,
																				  metrics: nil,
																				  serializationDuration: 0,
																				  result: .success(firmwareResponses))
		return Just(response).eraseToAnyPublisher()
	}
	
	func getUserDeviceById(deviceId: String) throws -> AnyPublisher<DataResponse<NetworkDevicesResponse, NetworkErrorResponse>, Never> {
		let device = NetworkDevicesResponse()
		let response = DataResponse<NetworkDevicesResponse, NetworkErrorResponse>(request: nil,
																				  response: nil,
																				  data: nil,
																				  metrics: nil,
																				  serializationDuration: 0,
																				  result: .success(device))
		return Just(response).eraseToAnyPublisher()
	}
	
	func getUserDeviceHourlyHistoryById(deviceId: String,
										date: Date,
										force: Bool) throws -> AnyPublisher<DataResponse<[NetworkDeviceHistoryResponse], NetworkErrorResponse>, Never> {
		let history = [NetworkDeviceHistoryResponse]()
		let response = DataResponse<[NetworkDeviceHistoryResponse], NetworkErrorResponse>(request: nil,
																						  response: nil,
																						  data: nil,
																						  metrics: nil,
																						  serializationDuration: 0,
																						  result: .success(history))
		return Just(response).eraseToAnyPublisher()
	}
	
	func getUserDeviceForecastById(deviceId: String,
								   fromDate: String,
								   toDate: String,
								   exclude: String) throws -> AnyPublisher<DataResponse<[NetworkDeviceForecastResponse], NetworkErrorResponse>, Never> {
		let forecast = [NetworkDeviceForecastResponse]()
		let response = DataResponse<[NetworkDeviceForecastResponse], NetworkErrorResponse>(request: nil,
																						   response: nil,
																						   data: nil,
																						   metrics: nil,
																						   serializationDuration: 0,
																						   result: .success(forecast))
		return Just(response).eraseToAnyPublisher()
	}
	
	func getUserDeviceRewardAnalytics(deviceId: String,
									  mode: DeviceRewardsMode) throws -> AnyPublisher<DataResponse<NetworkDeviceRewardsResponse, NetworkErrorResponse>, Never> {
		let rewardResponse = NetworkDeviceRewardsResponse(total: 0.0, data: nil, details: nil)
		let response = DataResponse<NetworkDeviceRewardsResponse, NetworkErrorResponse>(request: nil,
																						response: nil,
																						data: nil,
																						metrics: nil,
																						serializationDuration: 0,
																						result: .success(rewardResponse))
		return Just(response).eraseToAnyPublisher()
	}
	
	func getUserDevicesRewardAnalytics(mode: DeviceRewardsMode) throws -> AnyPublisher<DataResponse<NetworkDevicesRewardsResponse, NetworkErrorResponse>, Never> {
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
		let emptyEntity = EmptyEntity()
		let response = DataResponse<EmptyEntity, NetworkErrorResponse>(request: nil,
																	   response: nil,
																	   data: nil,
																	   metrics: nil,
																	   serializationDuration: 0,
																	   result: .success(emptyEntity))
		return Just(response).eraseToAnyPublisher()
	}
	
	func followStation(deviceId: String) throws -> AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never> {
		let emptyEntity = EmptyEntity()
		let response = DataResponse<EmptyEntity, NetworkErrorResponse>(request: nil,
																	   response: nil,
																	   data: nil,
																	   metrics: nil,
																	   serializationDuration: 0,
																	   result: .success(emptyEntity))
		return Just(response).eraseToAnyPublisher()
	}
	
	func unfollowStation(deviceId: String) throws -> AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never> {
		let emptyEntity = EmptyEntity()
		let response = DataResponse<EmptyEntity, NetworkErrorResponse>(request: nil,
																	   response: nil,
																	   data: nil,
																	   metrics: nil,
																	   serializationDuration: 0,
																	   result: .success(emptyEntity))
		return Just(response).eraseToAnyPublisher()
	}
	
	func getDeviceFollowState(deviceId: String) async throws -> Result<UserDeviceFollowState?, NetworkErrorResponse> {
		let constant = Constants(rawValue: deviceId)
		switch constant {
			case .followedDeviceId:
				let state = UserDeviceFollowState(deviceId: deviceId,
												  relation: .followed)
				return .success(state)
			case .ownedDeviceId:
				let state = UserDeviceFollowState(deviceId: deviceId,
												  relation: .owned)
				return .success(state)
			default:
				return .success(nil)
		}
	}
	
	func getUserDevicesFollowStates() async throws -> Result<[UserDeviceFollowState]?, NetworkErrorResponse> {
		.success(nil)
	}
	
	func setDeviceLocationById(deviceId: String, lat: Double, lon: Double) throws -> AnyPublisher<DataResponse<NetworkDevicesResponse, NetworkErrorResponse>, Never> {
		let device = NetworkDevicesResponse()
		let response = DataResponse<NetworkDevicesResponse, NetworkErrorResponse>(request: nil,
																				  response: nil,
																				  data: nil,
																				  metrics: nil,
																				  serializationDuration: 0,
																				  result: .success(device))
		return Just(response).eraseToAnyPublisher()
	}
	
	func setNotificationsFcmToken(installationId: String, token: String) throws -> AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never> {
		let emptyEntity = EmptyEntity()
		let response = DataResponse<EmptyEntity, NetworkErrorResponse>(request: nil,
																	   response: nil,
																	   data: nil,
																	   metrics: nil,
																	   serializationDuration: 0,
																	   result: .success(emptyEntity))
		return Just(response).eraseToAnyPublisher()
	}
}
