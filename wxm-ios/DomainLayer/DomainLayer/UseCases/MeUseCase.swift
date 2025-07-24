//
//  MeUseCase.swift
//  DomainLayer
//
//  Created by Hristos Condrea on 17/5/22.
//

import Alamofire
import Combine
import Foundation
import Toolkit

public struct MeUseCase: @unchecked Sendable, MeUseCaseApi {
    private let meRepository: MeRepository
	private let networkRepository: NetworkRepository
    private let filtersRepository: FiltersRepository
	private let userDefaultsrRepository: UserDefaultsRepository
    private let cancellables: CancellableWrapper = .init()

	public init(meRepository: MeRepository, filtersRepository: FiltersRepository, networkRepository: NetworkRepository, userDefaultsrRepository: UserDefaultsRepository) {
        self.meRepository = meRepository
        self.filtersRepository = filtersRepository
		self.networkRepository = networkRepository
		self.userDefaultsrRepository = userDefaultsrRepository
    }

	public var userInfoPublisher: AnyPublisher<NetworkUserInfoResponse?, Never> {
		meRepository.userInfoPublisher
	}

	public var userDevicesListChangedPublisher: NotificationCenter.Publisher {
		meRepository.userDevicesChangedNotificationPublisher
	}

	public func shouldShowAddButtonIndication() async -> Bool {
		let isSeen: Bool = userDefaultsrRepository.getValue(for: UserDefaults.GenericKey.isAddButtonIndicationSeen.rawValue) ?? false
		let hasOwnedDevices = await hasOwnedDevices()

		return !hasOwnedDevices && !isSeen
	}

	public func markAddButtonIndicationAsSeen() {
		userDefaultsrRepository.saveValue(key: UserDefaults.GenericKey.isAddButtonIndicationSeen.rawValue,
										  value: true)
	}

    public func getUserInfo() throws -> AnyPublisher<DataResponse<NetworkUserInfoResponse, NetworkErrorResponse>, Never> {
        let userInfo = try meRepository.getUser()
        return userInfo
    }

    public func getUserWallet() throws -> AnyPublisher<DataResponse<Wallet, NetworkErrorResponse>, Never> {
        let userWallet = try meRepository.getUserWallet()
        return userWallet
    }

    public func saveUserWallet(address: String) throws -> AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never> {
        let saveUserWallet = try meRepository.saveUserWallet(address: address)
        return saveUserWallet
    }

	public func getOwnedDevices() throws -> AnyPublisher<Result<[DeviceDetails], NetworkErrorResponse>, Never> {
		try meRepository.getOwnedDevices().convertedToDeviceDetailsResultPublisher
	}

    public func getDevices() throws -> AnyPublisher<Result<[DeviceDetails], NetworkErrorResponse>, Never> {
        let userDevices = try meRepository.getDevices(useCache: false)
        return userDevices.convertedToDeviceDetailsResultPublisher
    }

    public func claimDevice(claimDeviceBody: ClaimDeviceBody) throws -> AnyPublisher<Result<DeviceDetails, NetworkErrorResponse>, Never> {
        let claimDevice = try meRepository.claimDevice(claimDeviceBody: claimDeviceBody)
        return claimDevice.convertedToDeviceDetailsResultPublisher
    }

	public func setFrequency(_ serialNumber: String, frequency: Frequency) async throws -> NetworkErrorResponse? {
		let response = try await meRepository.setFrequency(serialNumber: serialNumber, frequency: frequency.rawValue).toAsync()
		return response.error
	}

    public func getFirmwares(testSearch: String) throws -> AnyPublisher<DataResponse<[NetworkFirmwareResponse], NetworkErrorResponse>, Never> {
        let getFirmwares = try meRepository.getFirmwares(testSearch: testSearch)
        return getFirmwares
    }

    public func getUserDeviceById(deviceId: String) throws -> AnyPublisher<Result<DeviceDetails, NetworkErrorResponse>, Never> {
        let getDeviceById = try meRepository.getUserDeviceById(deviceId: deviceId)
        return getDeviceById.convertedToDeviceDetailsResultPublisher
    }

    public func getUserDeviceForecastById(deviceId: String,
										  fromDate: String,
										  toDate: String,
										  exclude: String = "") throws -> AnyPublisher<DataResponse<[NetworkDeviceForecastResponse], NetworkErrorResponse>, Never> {
        let getUserDeviceForecastById = try meRepository.getUserDeviceForecastById(deviceId: deviceId, fromDate: fromDate, toDate: toDate, exclude: exclude)
        return getUserDeviceForecastById
    }


	public func getUserDeviceRewards(deviceId: String,
									 mode: DeviceRewardsMode) throws -> AnyPublisher<DataResponse<NetworkDeviceRewardsResponse, NetworkErrorResponse>, Never> {
		let getUserDeviceRewards = try meRepository.getUserDeviceRewardAnalytics(deviceId: deviceId, mode: mode)
		return getUserDeviceRewards
	}

	public func getUserDevicesRewards(mode: DeviceRewardsMode) throws -> AnyPublisher<DataResponse<NetworkDevicesRewardsResponse, NetworkErrorResponse>, Never> {
		let getUserDeviceRewards = try meRepository.getUserDevicesRewardAnalytics(mode: mode)
		return getUserDeviceRewards
	}

    public func deleteAccount() throws -> AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never> {
        let deleteAccount = try meRepository.deleteAccount()
        return deleteAccount
    }

    public func followStation(deviceId: String) async throws ->  Result<EmptyEntity, NetworkErrorResponse> {
        let followStation = try meRepository.followStation(deviceId: deviceId)
        return await withCheckedContinuation { continuation in
            followStation.sink { response in
                continuation.resume(returning: response.result)
            }.store(in: &cancellables.cancellableSet)
        }
    }

    public func unfollowStation(deviceId: String) async throws ->  Result<EmptyEntity, NetworkErrorResponse> {
        let unfollowStation = try meRepository.unfollowStation(deviceId: deviceId)
        return await withCheckedContinuation { continuation in
            unfollowStation.sink { response in
                continuation.resume(returning: response.result)
            }.store(in: &cancellables.cancellableSet)
        }
    }

    public func getDeviceFollowState(deviceId: String) async throws -> Result<UserDeviceFollowState?, NetworkErrorResponse> {
        try await meRepository.getDeviceFollowState(deviceId: deviceId)
    }

    public func getFiltersPublisher() -> AnyPublisher<FilterValues, Never> {
        filtersRepository.getFiltersPublisher()
    }

	public func hasOwnedDevices() async -> Bool {
		let states = try? await meRepository.getUserDevicesFollowStates().get()
		return states?.contains(where: { $0.relation == .owned }) ?? false
	}

	public func getUserRewards(wallet: String) throws -> AnyPublisher<DataResponse<NetworkUserRewardsResponse, NetworkErrorResponse>, Never> {
		try networkRepository.getRewardsWithdraw(wallet: wallet)
	}

	public func setDeviceLocationById(deviceId: String, lat: Double, lon: Double) throws -> AnyPublisher<Result<DeviceDetails, NetworkErrorResponse>, Never> {
		let publisher = try meRepository.setDeviceLocationById(deviceId: deviceId, lat: lat, lon: lon)
		return publisher.convertedToDeviceDetailsResultPublisher
	}

	public func shouldSendNotificationAlert(for deviceId: String, alert: StationAlert) -> Bool {
		true
	}

	public func notificationAlertSent(for deviceId: String, alert: StationAlert) {
		
	}
}
