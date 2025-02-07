//
//  MeRepositoryImpl.swift
//  DataLayer
//
//  Created by Danae Kikue Dimou on 18/5/22.
//

import Alamofire
import Combine
@preconcurrency import DomainLayer
import Foundation
import Toolkit

public struct MeRepositoryImpl: MeRepository {

	private let cancellableWrapper = CancellableWrapper()
	private let userDevicesService: UserDevicesService
	private let userInfoService: UserInfoService

	public init(userDevicesService: UserDevicesService, userInfoService: UserInfoService) {
		self.userDevicesService = userDevicesService
		self.userInfoService = userInfoService
	}

	public var userDevicesChangedNotificationPublisher: NotificationCenter.Publisher {
		userDevicesService.devicesListUpdatedPublisher
	}

	public var userInfoPublisher: AnyPublisher<NetworkUserInfoResponse?, Never> {
		userInfoService.getLatestUserInfoPublisher()
	}

    public func deleteAccount() throws -> AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never> {
		let builder = MeApiRequestBuilder.deleteAccount
        let urlRequest = try builder.asURLRequest()

		return ApiClient.shared.requestCodableAuthorized(urlRequest, mockFileName: builder.mockFileName)
    }

    public func getUser() throws -> AnyPublisher<DataResponse<NetworkUserInfoResponse, NetworkErrorResponse>, Never> {
		try userInfoService.getUser()
    }

    public func getUserWallet() throws -> AnyPublisher<DataResponse<Wallet, NetworkErrorResponse>, Never> {
        let builder =  MeApiRequestBuilder.getUserWallet
        let urlRequest = try builder.asURLRequest()
        return ApiClient.shared.requestCodableAuthorized(urlRequest, mockFileName: builder.mockFileName)
    }

    public func saveUserWallet(address: String) throws -> AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never> {
		return try userInfoService.saveUserWallet(address: address)
    }

	public func getCachedDevices() -> [NetworkDevicesResponse]? {
		userDevicesService.getCachedDevices()
	}
	
	public func getDevices(useCache: Bool) throws -> AnyPublisher<DataResponse<[NetworkDevicesResponse], NetworkErrorResponse>, Never> {
        try userDevicesService.getDevices(useCache: useCache)
    }

    public func claimDevice(claimDeviceBody: ClaimDeviceBody) throws -> AnyPublisher<DataResponse<NetworkDevicesResponse, NetworkErrorResponse>, Never> {
        try userDevicesService.claimDevice(claimDeviceBody: claimDeviceBody)
    }

	public func setFrequency(serialNumber: String, frequency: String) throws -> AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never> {
		let builder = MeApiRequestBuilder.setDeviceFrequency(serialNumber: serialNumber, frequency: frequency)
		let urlRequest = try builder.asURLRequest()

		return ApiClient.shared.requestCodableAuthorized(urlRequest, mockFileName: builder.mockFileName)
	}

    public func getFirmwares(testSearch: String) throws -> AnyPublisher<DataResponse<[NetworkFirmwareResponse], NetworkErrorResponse>, Never> {
        let urlRequest = try MeApiRequestBuilder.getFirmwares(testSearch: testSearch).asURLRequest()
        return ApiClient.shared.requestCodableAuthorized(urlRequest)
    }

    public func getUserDeviceById(deviceId: String) throws -> AnyPublisher<DataResponse<NetworkDevicesResponse, NetworkErrorResponse>, Never> {
        try userDevicesService.getUserDeviceById(deviceId: deviceId)
    }

    public func getUserDeviceHourlyHistoryById(deviceId: String,
											   date: Date,
											   force: Bool) throws -> AnyPublisher<DataResponse<[NetworkDeviceHistoryResponse], NetworkErrorResponse>, Never> {
        // If there are enough persisted samples for the date,
        // we return the local samples, otherwise we perform a server request
        let dateString = date.getFormattedDate(format: .onlyDate)
        guard !force,
              let persistedData = getPersistedHistoricalData(deviceId: deviceId,
                                                             date: dateString).first,
              isDailyHistoricalDataCompleted(history: persistedData) else {
            return try fetchUserDeviceHistoryById(deviceId: deviceId, fromDate: dateString, toDate: dateString, exclude: .daily)
        }

        return Just(DataResponse(request: nil,
                                 response: nil,
                                 data: nil,
                                 metrics: nil,
                                 serializationDuration: 0,
                                 result: .success([persistedData]))).eraseToAnyPublisher()
    }

    public func getUserDeviceForecastById(deviceId: String,
										  fromDate: String,
										  toDate: String,
										  exclude: String) throws -> AnyPublisher<DataResponse<[NetworkDeviceForecastResponse], NetworkErrorResponse>, Never> {
        let builder = MeApiRequestBuilder.getUserDeviceForecastById(deviceId: deviceId, fromDate: fromDate, toDate: toDate, exclude: exclude)
        let urlRequest = try builder.asURLRequest()
        return ApiClient.shared.requestCodableAuthorized(urlRequest, mockFileName: builder.mockFileName)
    }

	public func getUserDeviceRewardAnalytics(deviceId: String, mode: DeviceRewardsMode) throws -> AnyPublisher<DataResponse<NetworkDeviceRewardsResponse, NetworkErrorResponse>, Never> {
		let builder = MeApiRequestBuilder.getUserDeviceRewards(deviceId: deviceId, mode: mode.rawValue)
		let urlRequest = try builder.asURLRequest()
		return ApiClient.shared.requestCodableAuthorized(urlRequest, mockFileName: builder.mockFileName)
	}

	public func getUserDevicesRewardAnalytics(mode: DeviceRewardsMode) throws -> AnyPublisher<DataResponse<NetworkDevicesRewardsResponse, NetworkErrorResponse>, Never> {
		let builder = MeApiRequestBuilder.getUserDevicesRewards(mode: mode.rawValue)
		let urlRequest = try builder.asURLRequest()
		return ApiClient.shared.requestCodableAuthorized(urlRequest, mockFileName: builder.mockFileName)
	}

    public func followStation(deviceId: String) throws -> AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never> {
        try userDevicesService.followStation(deviceId: deviceId)
    }

    public func unfollowStation(deviceId: String) throws -> AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never> {
        try userDevicesService.unfollowStation(deviceId: deviceId)
    }

    public func getDeviceFollowState(deviceId: String) async throws -> Result<UserDeviceFollowState?, NetworkErrorResponse> {
        guard KeychainHelperService().isUserLoggedIn() else {
            return .success(nil)
        }

        return try await userDevicesService.getFollowState(deviceId: deviceId)
    }

	public func getUserDevicesFollowStates() async throws -> Result<[UserDeviceFollowState]?, NetworkErrorResponse> {
		guard KeychainHelperService().isUserLoggedIn() else {
			return .success(nil)
		}

		return try await userDevicesService.getFollowStates()
	}

	public func setDeviceLocationById(deviceId: String, lat: Double, lon: Double) throws -> AnyPublisher<DataResponse<NetworkDevicesResponse, NetworkErrorResponse>, Never> {
		try userDevicesService.setDeviceLocationById(deviceId: deviceId, lat: lat, lon: lon)
	}

	public func setNotificationsFcmToken(installationId: String, token: String) throws -> AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never> {
		let builder = MeApiRequestBuilder.setFCMToken(installationId: installationId, token: token)
		let urlRequest = try builder.asURLRequest()
		return ApiClient.shared.requestCodableAuthorized(urlRequest, mockFileName: builder.mockFileName)
	}

	func getPersistedHistoricalData(deviceId: String, date: String) -> [NetworkDeviceHistoryResponse] {
		let predicate = NSPredicate(format: "\(#keyPath(DBWeather.deviceId)) == %@ AND (\(#keyPath(DBWeather.dateString)) == %@)", deviceId, date)
		let hourly = DatabaseService.shared.fetchWeatherFromDB(predicate: predicate)

		var days: [String: [DBWeather]] = [:]
		hourly.forEach { dbWeather in
			guard let dateString = dbWeather.dateString else {
				return
			}

			var hours = days[dateString] ?? []
			hours.append(dbWeather)
			days[dateString] = hours
		}

		let historicalData: [NetworkDeviceHistoryResponse] = days.map {
			NetworkDeviceHistoryResponse(tz: $0.value.first?.tz ?? "", date: $0.key, hourly: $0.value.compactMap { $0.toCodable })
		}

		return historicalData
	}
}

private extension MeRepositoryImpl {

    func saveHistoricalData(deviceId: String, historicalData: [NetworkDeviceHistoryResponse]) {
        historicalData.forEach { response in
            response.hourly?.forEach { weather in
                guard let object = weather.toManagedObject else {
                    return
                }
                object.deviceId = deviceId
                object.tz = response.tz
                object.dateString = response.date
                DatabaseService.shared.save(object: object)
            }
        }
    }

    /// Checks if the passed forecast objects contains at least 24 samples. One additional condition is the fisrt sample's timestamp  should be within 2 hours from the day start
    ///  and the last sample's timestamp should be max 2 hours earlier than end of day.
    /// - Parameter history: The forecast object to be validated
    /// - Returns: `True` if is completed
    func isDailyHistoricalDataCompleted(history: NetworkDeviceHistoryResponse) -> Bool {
        let threshold: TimeInterval = 2 * TimeInterval.hour

        guard let hourly = history.hourly,
              let timeZone = TimeZone(identifier: history.tz),
              let firstItemTimestamp = history.hourly?.first?.timestamp?.timestampToDate(timeZone: timeZone),
              let lastItemTimestamp = history.hourly?.last?.timestamp?.timestampToDate(timeZone: timeZone),
              case let startOfDay = firstItemTimestamp.startOfDay(timeZone: timeZone),
              let endOfDay = lastItemTimestamp.endOfDay,
              startOfDay.timeIntervalSince(firstItemTimestamp) < threshold,
              endOfDay.timeIntervalSince(lastItemTimestamp) < threshold
        else {
            return false
        }

        return hourly.count >= 24
    }

    func fetchUserDeviceHistoryById(deviceId: String,
									fromDate: String,
									toDate: String,
									exclude: HistoryExclude) throws -> AnyPublisher<DataResponse<[NetworkDeviceHistoryResponse], NetworkErrorResponse>, Never> {
        let builder = MeApiRequestBuilder.getUserDeviceHistoryById(deviceId: deviceId, fromDate: fromDate, toDate: toDate, exclude: exclude.rawValue)
        let urlRequest = try builder.asURLRequest()

        let publisher: AnyPublisher<DataResponse<[NetworkDeviceHistoryResponse], NetworkErrorResponse>, Never> = ApiClient.shared.requestCodableAuthorized(urlRequest,
																																						   mockFileName: builder.mockFileName)
        publisher.sink { response in
            guard let value = response.value else {
                return
            }
            // Once the reposnse is a successful we saved the retrieved data locally
            saveHistoricalData(deviceId: deviceId, historicalData: value)
        }
        .store(in: &cancellableWrapper.cancellableSet)

        return publisher
    }
}
