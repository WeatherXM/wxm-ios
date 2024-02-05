//
//  UserDevicesService.swift
//  DataLayer
//
//  Created by Pantelis Giazitsis on 6/8/23.
//

import Foundation
import Combine
import Alamofire
import DomainLayer
import Toolkit
import WidgetKit

extension Notification.Name {
    static let userDevicesListUpdated = Notification.Name("userDevices.updated")
}

public class UserDevicesService {

    private var cancellableSet: Set<AnyCancellable> = []
    private let cacheValidationInterval: TimeInterval = 3.0 * 60.0 // 3 minutes
	private let followStatesCache = TimeValidationCache<[UserDeviceFollowState]>(persistCacheManager: UserDefaultsService(),
																				 persistKey: UserDefaults.GenericKey.userDevicesFollowStates.rawValue) // Store user device follow states
	private let userDevicesCache = TimeValidationCache<[NetworkDevicesResponse]>(persistCacheManager: UserDefaultsService(),
																				 persistKey: UserDefaults.GenericKey.userDevices.rawValue) // Store user devices
    private let followStatesCacheKey = "userDevicesService.deviceFollowStates"
	private let userDevicesCacheKey = "userDevicesService.devices"
    let devicesListUpdatedPublisher = NotificationCenter.default.publisher(for: .userDevicesListUpdated)

    public init() {
        NotificationCenter.default.addObserver(forName: .keychainHelperServiceUserIsLoggedOut,
                                               object: nil,
											   queue: nil) { [weak self] _ in
			self?.invalidateCaches()
		}
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

	func getDevices(useCache: Bool) throws -> AnyPublisher<DataResponse<[NetworkDevicesResponse], NetworkErrorResponse>, Never> {
		if useCache, let cachedDevices = userDevicesCache.getValue(for: userDevicesCacheKey) {
			return Just(DataResponse(request: nil,
									 response: nil, 
									 data: nil,
									 metrics: nil, 
									 serializationDuration: 0.0,
									 result: .success(cachedDevices))).eraseToAnyPublisher()
		}

        let builder = MeApiRequestBuilder.getDevices
        let urlRequest = try builder.asURLRequest()
        let publisher: AnyPublisher<DataResponse<[NetworkDevicesResponse], NetworkErrorResponse>, Never> = ApiClient.shared.requestCodableAuthorized(urlRequest, mockFileName: builder.mockFileName)
        return publisher
            .flatMap { [weak self, cacheValidationInterval, followStatesCacheKey, userDevicesCacheKey] response in
                if let value = response.value {
                    let states: [UserDeviceFollowState] = value.compactMap { device in
                        guard let deviceId = device.id  else {
                            return nil
                        }
                        let relation: DeviceRelation = device.relation ?? .followed
                        return UserDeviceFollowState(deviceId: deviceId, relation: relation)
                    }

					self?.followStatesCache.insertValue(states,
														expire: cacheValidationInterval,
														for: followStatesCacheKey)
					self?.userDevicesCache.insertValue(value,
													   expire: cacheValidationInterval,
													   for: userDevicesCacheKey)

					WidgetCenter.shared.reloadAllTimelines()
					
                    NotificationCenter.default.post(name: .userDevicesListUpdated, object: nil)
                }
                return Just(response)
            }
            .eraseToAnyPublisher()
    }

    func claimDevice(claimDeviceBody: ClaimDeviceBody) throws -> AnyPublisher<DataResponse<NetworkDevicesResponse, NetworkErrorResponse>, Never> {
        let urlRequest = try MeApiRequestBuilder.claimDevice(claimDeviceBody: claimDeviceBody).asURLRequest()
        let publisher: AnyPublisher<DataResponse<NetworkDevicesResponse, NetworkErrorResponse>, Never> = ApiClient.shared.requestCodableAuthorized(urlRequest)
        return publisher
            .flatMap { [weak self] response in
                if response.error == nil {
					self?.invalidateCaches()
					WidgetCenter.shared.reloadAllTimelines()
                }
                return Just(response)
            }
            .eraseToAnyPublisher()
    }

	func disclaimDevice(serialNumber: String) throws -> AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never> {
		let urlRequest = try MeApiRequestBuilder.disclaimDevice(serialNumber: serialNumber).asURLRequest()
		let publisher: AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never> = ApiClient.shared.requestCodableAuthorized(urlRequest)

		return publisher
			.flatMap { [weak self] response in
				if response.error == nil {
					self?.invalidateCaches()
					WidgetCenter.shared.reloadAllTimelines()
				}
				return Just(response)
			}
			.eraseToAnyPublisher()
	}


    public func getUserDeviceById(deviceId: String) throws -> AnyPublisher<DataResponse<NetworkDevicesResponse, NetworkErrorResponse>, Never> {
        let builder = MeApiRequestBuilder.getUserDeviceById(deviceId: deviceId)
        let urlRequest = try builder.asURLRequest()
        let publisher: AnyPublisher<DataResponse<NetworkDevicesResponse, NetworkErrorResponse>, Never> = ApiClient.shared.requestCodableAuthorized(urlRequest, mockFileName: builder.mockFileName)
        return publisher
    }

    func followStation(deviceId: String) throws -> AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never> {
        let builder = MeApiRequestBuilder.follow(deviceId: deviceId)
        let urlRequest = try builder.asURLRequest()
        let publisher: AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never> = ApiClient.shared.requestCodableAuthorized(urlRequest, mockFileName: builder.mockFileName)
        return publisher
            .flatMap { [weak self] response in
                if response.error == nil {
					self?.invalidateCaches()
					WidgetCenter.shared.reloadAllTimelines()
                }
                return Just(response)
            }
            .eraseToAnyPublisher()
    }

    func unfollowStation(deviceId: String) throws -> AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never> {
        let builder = MeApiRequestBuilder.unfollow(deviceId: deviceId)
        let urlRequest = try builder.asURLRequest()
        let publisher: AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never> = ApiClient.shared.requestCodableAuthorized(urlRequest, mockFileName: builder.mockFileName)
        return publisher
            .flatMap { [weak self] response in
                if response.error == nil {
					self?.invalidateCaches()
					WidgetCenter.shared.reloadAllTimelines()
                }
                return Just(response)
            }
            .eraseToAnyPublisher()
    }

    func getFollowState(deviceId: String) async throws -> Result<UserDeviceFollowState?, NetworkErrorResponse> {
        // If the id is in cache the device id is for a user device
        if let cachedStates = followStatesCache.getValue(for: followStatesCacheKey) {
            return .success(cachedStates.first(where: { $0.deviceId == deviceId }))
        }

        return try await withUnsafeThrowingContinuation { continuation in
            do {
                let getDevices = try getDevices(useCache: false)
				getDevices.sink { response in
                    if let error = response.error {
                        continuation.resume(returning: .failure(error))
                    } else {
                        guard let userDevice = (response.value ?? []).first(where: { $0.id == deviceId }),
                              let deviceId = userDevice.id,
                              let relation = userDevice.relation else {
                            continuation.resume(returning: .success(nil))
                            return
                        }
                        let userDeviceState = UserDeviceFollowState(deviceId: deviceId, relation: relation)
                        continuation.resume(returning: .success(userDeviceState))
                    }
                }
                .storeThreadSafe(in: &cancellableSet)

            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

	func getFollowStates() async throws -> Result<[UserDeviceFollowState]?, NetworkErrorResponse> {
		if let cachedStates = followStatesCache.getValue(for: followStatesCacheKey) {
			return .success(cachedStates)
		}

		return try await withUnsafeThrowingContinuation { continuation in
			do {
				try getDevices(useCache: false).handleEvents(receiveCompletion: { [weak self]  _ in
					let cachedStates = self?.followStatesCache.getValue(for: self?.followStatesCacheKey ?? "")
					continuation.resume(returning: .success(cachedStates))
				}).sink { _ in }.storeThreadSafe(in: &cancellableSet)
			} catch {
				continuation.resume(throwing: error)
			}
		}
	}

	func setDeviceLocationById(deviceId: String, lat: Double, lon: Double) throws -> AnyPublisher<DataResponse<NetworkDevicesResponse, NetworkErrorResponse>, Never> {
		let builder = MeApiRequestBuilder.setDeviceLocation(deviceId: deviceId, lat: lat, lon: lon)
		let urlRequest = try builder.asURLRequest()
		let publisher: AnyPublisher<DataResponse<NetworkDevicesResponse, NetworkErrorResponse>, Never> = ApiClient.shared.requestCodableAuthorized(urlRequest, mockFileName: builder.mockFileName)
		return publisher
			.flatMap { [weak self] response in
				if response.error == nil {
					self?.invalidateCaches()
					WidgetCenter.shared.reloadAllTimelines()
					NotificationCenter.default.post(name: .userDevicesListUpdated, object: deviceId)
				}
				return Just(response)
			}
			.eraseToAnyPublisher()
	}

	func setFriendlyName(deviceId: String, name: String) throws -> AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never> {
		let urlRequest = try MeApiRequestBuilder.setFriendlyName(deviceId: deviceId, name: name).asURLRequest()
		let publisher: AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never> = ApiClient.shared.requestCodableAuthorized(urlRequest)
		return publisher
			.flatMap { [weak self] response in
				if response.error == nil {
					self?.invalidateCaches()
					WidgetCenter.shared.reloadAllTimelines()
					NotificationCenter.default.post(name: .userDevicesListUpdated, object: deviceId)
				}
				return Just(response)
			}
			.eraseToAnyPublisher()
	}

	func deleteFriendlyName(deviceId: String) throws -> AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never> {
		let urlRequest = try MeApiRequestBuilder.deleteFriendlyName(deviceId: deviceId).asURLRequest()
		let publisher: AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never> = ApiClient.shared.requestCodableAuthorized(urlRequest)
		return publisher
			.flatMap { [weak self] response in
				if response.error == nil {
					self?.invalidateCaches()
					WidgetCenter.shared.reloadAllTimelines()
					NotificationCenter.default.post(name: .userDevicesListUpdated, object: deviceId)
				}
				return Just(response)
			}
			.eraseToAnyPublisher()
	}
}

private extension UserDevicesService {
	func invalidateCaches() {
		followStatesCache.invalidate()
		userDevicesCache.invalidate()
	}
}
