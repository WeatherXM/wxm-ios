//
//  DeviceDetailsUseCase.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 31/7/23.
//

import Foundation
import Combine
import Alamofire
import Toolkit
import CoreLocation

public struct DeviceDetailsUseCase {

    private let meRepository: MeRepository
    private let explorerRepository: ExplorerRepository
    private let keychainRepository: KeychainRepository
    private let cancellables: CancellableWrapper = .init()

    public init(meRepository: MeRepository, explorerRepository: ExplorerRepository, keychainRepository: KeychainRepository) {
        self.meRepository = meRepository
        self.explorerRepository = explorerRepository
        self.keychainRepository = keychainRepository
    }

    public func getDeviceDetailsById(deviceId: String, cellIndex: String?) async throws -> Result<DeviceDetails, NetworkErrorResponse> {
        let followStateResult = try await meRepository.getDeviceFollowState(deviceId: deviceId)
        switch followStateResult {
            case .success(let followState):
                if let followState {
                    return try await getUserDeviceById(deviceId: deviceId)
                }

                return try await getPublicDeviceById(deviceId: deviceId,
                                                     cellIndex: cellIndex)
            case .failure(let error):
                return .failure(error)
        }
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

    public func resolveAddress(location: CLLocationCoordinate2D) async throws -> String {
        let geocoder = Geocoder()
        return try await geocoder.resolveAddressLocation(location)
    }

    public func getDeviceFollowState(deviceId: String) async throws -> Result<UserDeviceFollowState?, NetworkErrorResponse> {
        try await meRepository.getDeviceFollowState(deviceId: deviceId)
    }
}

private extension DeviceDetailsUseCase {

    func getUserDeviceById(deviceId: String) async throws -> Result<DeviceDetails, NetworkErrorResponse> {
        return try await withCheckedThrowingContinuation { continuation in
            do {
                let getDeviceById: AnyPublisher<DataResponse<NetworkDevicesResponse, NetworkErrorResponse>, Never> = try meRepository.getUserDeviceById(deviceId: deviceId)
                getDeviceById.sink { response in
                    if let error = response.error {
                        continuation.resume(returning: .failure(error))
                    } else {
                        continuation.resume(returning: .success(response.value!.toDeviceDetails))
                    }
                }
                .store(in: &cancellables.cancellableSet)
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    func getPublicDeviceById(deviceId: String, cellIndex: String?) async throws -> Result<DeviceDetails, NetworkErrorResponse> {
        return try await withCheckedThrowingContinuation { continuation in
            guard let cellIndex else {
//                continuation.resume(throwing: ExplorerLocationError.)
                return
            }
            do {
                let getPublicDeviceById = try explorerRepository.getPublicDevice(index: cellIndex, deviceId: deviceId)
                getPublicDeviceById.sink { response in
                    if let error = response.error {
                        continuation.resume(returning: .failure(error))
                    } else {
                        continuation.resume(returning: .success(response.value!.toDeviceDetails))
                    }
                }
                .store(in: &cancellables.cancellableSet)
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}
