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

public struct MeUseCase {
    private let meRepository: MeRepository
	private let networkRepository: NetworkRepository
    private let filtersRepository: FiltersRepository
    private let cancellables: CancellableWrapper = .init()

	public init(meRepository: MeRepository, filtersRepository: FiltersRepository, networkRepository: NetworkRepository) {
        self.meRepository = meRepository
        self.filtersRepository = filtersRepository
		self.networkRepository = networkRepository
    }

	public var userInfoPublisher: AnyPublisher<NetworkUserInfoResponse?, Never> {
		meRepository.userInfoPublisher
	}

	public var userDevicesListChangedPublisher: NotificationCenter.Publisher {
		meRepository.userDevicesChangedNotificationPublisher
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

    public func getDevices() throws -> AnyPublisher<Result<[DeviceDetails], NetworkErrorResponse>, Never> {
        let userDevices = try meRepository.getDevices(useCache: false)
        return userDevices.convertedToDeviceDetailsResultPublisher
    }

    public func claimDevice(claimDeviceBody: ClaimDeviceBody) throws -> AnyPublisher<Result<DeviceDetails, NetworkErrorResponse>, Never> {
        let claimDevice = try meRepository.claimDevice(claimDeviceBody: claimDeviceBody)
        return claimDevice.convertedToDeviceDetailsResultPublisher
    }

    public func getFirmwares(testSearch: String) throws -> AnyPublisher<DataResponse<[NetworkFirmwareResponse], NetworkErrorResponse>, Never> {
        let getFirmwares = try meRepository.getFirmwares(testSearch: testSearch)
        return getFirmwares
    }

    public func getUserDeviceById(deviceId: String) throws -> AnyPublisher<Result<DeviceDetails, NetworkErrorResponse>, Never> {
        let getDeviceById = try meRepository.getUserDeviceById(deviceId: deviceId)
        return getDeviceById.convertedToDeviceDetailsResultPublisher
    }

    public func getUserDeviceForecastById(deviceId: String, fromDate: String, toDate: String, exclude: String = "") throws -> AnyPublisher<DataResponse<[NetworkDeviceForecastResponse], NetworkErrorResponse>, Never> {
        let getUserDeviceForecastById = try meRepository.getUserDeviceForecastById(deviceId: deviceId, fromDate: fromDate, toDate: toDate, exclude: exclude)
        return getUserDeviceForecastById
    }

    public func getUserDeviceTokensTransactionsById(deviceId: String, page: Int, pageSize: Int, timezone: String, fromDate: String, toDate: String) throws -> AnyPublisher<DataResponse<NetworkDeviceIDTokensTransactionsResponse, NetworkErrorResponse>, Never> {
        let getUserDeviceTokensTransactionsById = try meRepository.getUserDeviceTokensTransactionsById(deviceId: deviceId, page: page, pageSize: pageSize, timezone: timezone, fromDate: fromDate, toDate: toDate)
        return getUserDeviceTokensTransactionsById
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
}
