//
//  UserDevicesService.swift
//  DataLayer
//
//  Created by Pantelis Giazitsis on 6/8/23.
//

import Foundation
import Combine
import Alamofire
@preconcurrency import DomainLayer
import Toolkit
import WidgetKit

extension Notification.Name {
    static let userDevicesListUpdated = Notification.Name("userDevices.updated")
}

public class UserDevicesService: @unchecked Sendable {

    private var cancellableSet: Set<AnyCancellable> = []
    private let cacheValidationInterval: TimeInterval = 3.0 * 60.0 // 3 minutes
	private let followStatesCache: TimeValidationCache<[UserDeviceFollowState]> // Store user device follow states
	private let userDevicesCache: TimeValidationCache<[NetworkDevicesResponse]> // Store user devices
    private let followStatesCacheKey = "userDevicesService.deviceFollowStates"
	private let userDevicesCacheKey = "userDevicesService.devices"
    let devicesListUpdatedPublisher = NotificationCenter.default.publisher(for: .userDevicesListUpdated)

	public init(followStatesCacheManager: PersistCacheManager, userDevicesCacheManager: PersistCacheManager) {
		followStatesCache = TimeValidationCache<[UserDeviceFollowState]>(persistCacheManager: followStatesCacheManager,
																		 persistKey: UserDefaults.GenericKey.userDevicesFollowStates.rawValue)
		userDevicesCache  = TimeValidationCache<[NetworkDevicesResponse]>(persistCacheManager: userDevicesCacheManager,
																		  persistKey: UserDefaults.GenericKey.userDevices.rawValue)

        NotificationCenter.default.addObserver(forName: .keychainHelperServiceUserIsLoggedChanged,
                                               object: nil,
											   queue: nil) { [weak self] _ in
			self?.invalidateCaches()
			self?.updateStationsAnalyticsProperties()
		}

		updateStationsAnalyticsProperties()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

	func getCachedDevices() -> [NetworkDevicesResponse]? {
		userDevicesCache.getCachedValue(for: userDevicesCacheKey)
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
        let publisher: AnyPublisher<DataResponse<[NetworkDevicesResponse], NetworkErrorResponse>, Never> = ApiClient.shared.requestCodableAuthorized(urlRequest,
																																					 mockFileName: builder.mockFileName)
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
					self?.updateStationsAnalyticsProperties()
                }
                return Just(response)
            }
            .eraseToAnyPublisher()
    }

    func claimDevice(claimDeviceBody: ClaimDeviceBody) throws -> AnyPublisher<DataResponse<NetworkDevicesResponse, NetworkErrorResponse>, Never> {
		let builder = MeApiRequestBuilder.claimDevice(claimDeviceBody: claimDeviceBody)
		let urlRequest = try builder.asURLRequest()
		let publisher: AnyPublisher<DataResponse<NetworkDevicesResponse, NetworkErrorResponse>, Never> = ApiClient.shared.requestCodableAuthorized(urlRequest,
																																				   mockFileName: builder.mockFileName)
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
		let builder = MeApiRequestBuilder.disclaimDevice(serialNumber: serialNumber)
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

    public func getUserDeviceById(deviceId: String) throws -> AnyPublisher<DataResponse<NetworkDevicesResponse, NetworkErrorResponse>, Never> {
        let builder = MeApiRequestBuilder.getUserDeviceById(deviceId: deviceId)
        let urlRequest = try builder.asURLRequest()
        let publisher: AnyPublisher<DataResponse<NetworkDevicesResponse, NetworkErrorResponse>, Never> = ApiClient.shared.requestCodableAuthorized(urlRequest,
																																				   mockFileName: builder.mockFileName)
        return publisher
    }

    func followStation(deviceId: String) throws -> AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never> {
        let builder = MeApiRequestBuilder.follow(deviceId: deviceId)
        let urlRequest = try builder.asURLRequest()
        let publisher: AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never> = ApiClient.shared.requestCodableAuthorized(urlRequest,
																																		mockFileName: builder.mockFileName)
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
        let publisher: AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never> = ApiClient.shared.requestCodableAuthorized(urlRequest,
																																		mockFileName: builder.mockFileName)
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
                .store(in: &cancellableSet)

            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

	@MainActor
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
		let publisher: AnyPublisher<DataResponse<NetworkDevicesResponse, NetworkErrorResponse>, Never> = ApiClient.shared.requestCodableAuthorized(urlRequest,
																																				   mockFileName: builder.mockFileName)
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
		let builder = MeApiRequestBuilder.setFriendlyName(deviceId: deviceId, name: name)
		let urlRequest = try builder.asURLRequest()
		let publisher: AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never> = ApiClient.shared.requestCodableAuthorized(urlRequest,
																																		mockFileName: builder.mockFileName)
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
		let builder = MeApiRequestBuilder.deleteFriendlyName(deviceId: deviceId)
		let urlRequest = try builder.asURLRequest()
		let publisher: AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never> = ApiClient.shared.requestCodableAuthorized(urlRequest, mockFileName: builder.mockFileName)
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

	func updateStationsAnalyticsProperties() {
		guard let devices = getCachedDevices() else {
			WXMAnalytics.shared.removeUserProperty(key: .stationsOwn)
			WXMAnalytics.shared.removeUserProperty(key: .stationsFavorite)
			StationBundle.Code.allCases.forEach {
				WXMAnalytics.shared.removeUserProperty(key: .stationsOwnCount(stationType: $0.rawValue))
			}
			return
		}

		let ownedDevices = devices.filter({ $0.relation == .owned })
		let favoriteDevices = devices.filter({ $0.relation == .followed })

		WXMAnalytics.shared.setUserProperty(key: .stationsOwn, value: .custom("\(ownedDevices.count)"))
		WXMAnalytics.shared.setUserProperty(key: .stationsFavorite, value: .custom("\(favoriteDevices.count)"))

		let dict = Dictionary(grouping: ownedDevices, by: { $0.bundle?.name?.rawValue })
		dict.forEach { key, value in
			guard let key else {
				return
			}
			WXMAnalytics.shared.setUserProperty(key: .stationsOwnCount(stationType: key),
												value: .custom("\(value.count)"))
		}
	}
}
