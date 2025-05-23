//
//  ExplorerUseCase.swift
//  DomainLayer
//
//  Created by Lampros Zouloumis on 17/8/22.
//

@preconcurrency import Combine
import CoreLocation
import Foundation
@preconcurrency import MapboxMaps
import Toolkit
import UIKit

public class ExplorerUseCase: @unchecked Sendable, ExplorerUseCaseApi {
	private static let fillOpacity = 0.5
	private static let fillColor = StyleColor(red: 51.0, green: 136.0, blue: 255.0, alpha: 1.0)
	private static let fillOutlineColor = StyleColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)

	private let explorerRepository: ExplorerRepository
	private let devicesRepository: DevicesRepository
	private let meRepository: MeRepository
	private let deviceLocationRepository: DeviceLocationRepository
	let geocoder: GeocoderProtocol
	private var cancellableSet: Set<AnyCancellable> = []

	public init(explorerRepository: ExplorerRepository,
				devicesRepository: DevicesRepository,
				meRepository: MeRepository,
				deviceLocationRepository: DeviceLocationRepository,
				geocoder: GeocoderProtocol) {
		self.explorerRepository = explorerRepository
		self.devicesRepository = devicesRepository
		self.meRepository = meRepository
		self.deviceLocationRepository = deviceLocationRepository
		self.geocoder = geocoder
	}

	public var userDevicesListChangedPublisher: NotificationCenter.Publisher {
		meRepository.userDevicesChangedNotificationPublisher
	}

	public var userLocationAuthorizationStatus: WXMLocationManager.Status {
		explorerRepository.locationAuthorization
	}

	public func getUserLocation() async -> Result<CLLocationCoordinate2D, ExplorerLocationError> {
		await explorerRepository.getUserLocation()
	}

	public func getSuggestedDeviceLocation() -> CLLocationCoordinate2D? {
		guard let countryInfos = deviceLocationRepository.getCountryInfos() else {
			return nil
		}
		let code = Locale.current.regionCode
		let info = countryInfos.first(where: { $0.code == code })

		return info?.mapCenter
	}

	public func getCell(cellIndex: String) async throws -> Result<PublicHex?, NetworkErrorResponse> {
		let publisher = try explorerRepository.getPublicHexes()
		return await withUnsafeContinuation { continuation in
			publisher.sink { response in
				switch response.result {
					case .success(let cells):
						let cell = cells.first(where: { $0.index == cellIndex })
						continuation.resume(returning: .success(cell))
					case .failure(let error):
						continuation.resume(returning: .failure(error))
				}
			}.store(in: &cancellableSet)
		}
	}

	public func getPublicHexes() async throws -> Result<[PublicHex], NetworkErrorResponse> {
		try await explorerRepository.getPublicHexes().toAsync().result
	}

	public func getPublicDevicesOfHexIndex(hexIndex: String, hexCoordinates: CLLocationCoordinate2D?, completion: @escaping @Sendable (Result<[DeviceDetails], PublicHexError>) -> Void) {
		do {
			try explorerRepository.getPublicDevicesOfHex(index: hexIndex)
				.sink(receiveValue: { [weak self] response in
					guard let self, let devices = response.value, response.error == nil else {
						completion(.failure(PublicHexError.networkRelated(response.error)))
						return
					}

					Task { [weak self] in
						var explorerDevices = await devices.asyncMap { [weak self] publicDevice in
							_ = try? await self?.meRepository.getDeviceFollowState(deviceId: publicDevice.id).get()
							var device = publicDevice.toDeviceDetails
							if let hexCoordinates {
								device.cellCenter = LocationCoordinates(lat: hexCoordinates.latitude, long: hexCoordinates.longitude)
							}

							return device
						}
						explorerDevices = explorerDevices.sorted(by: { dev1, dev2 -> Bool in
							dev1.isActive == !dev2.isActive
						}).sorted(by: { dev1, dev2 -> Bool in
							if dev1.isActive == dev2.isActive {
								return dev1.name < dev2.name
							}
							return true
						})
						completion(.success(explorerDevices))
					}
				}).store(in: &cancellableSet)

		} catch {
			completion(.failure(PublicHexError.infrastructure))
		}
	}

	public func getPublicDevice(hexIndex: String, deviceId: String, completion: @escaping (Result<DeviceDetails, PublicHexError>) -> Void) {
		do {
			try self.explorerRepository.getPublicDevice(index: hexIndex, deviceId: deviceId)
				.sink { devicesResponse in
					guard let device = devicesResponse.value else {
						completion(.failure(PublicHexError.networkRelated(devicesResponse.error)))
						return
					}
					completion(.success(device.toDeviceDetails))
				}.store(in: &self.cancellableSet)
		} catch {
			completion(.failure(PublicHexError.infrastructure))
		}
	}

	public func followStation(deviceId: String) async throws -> Result<EmptyEntity, NetworkErrorResponse> {
		let followStation = try meRepository.followStation(deviceId: deviceId)
		return await withCheckedContinuation { continuation in
			followStation.sink { response in
				continuation.resume(returning: response.result)
			}.store(in: &cancellableSet)
		}
	}

	public func unfollowStation(deviceId: String) async throws -> Result<EmptyEntity, NetworkErrorResponse> {
		let unfollowStation = try meRepository.unfollowStation(deviceId: deviceId)
		return await withCheckedContinuation { continuation in
			unfollowStation.sink { response in
				continuation.resume(returning: response.result)
			}.store(in: &cancellableSet)
		}
	}

	public func getDeviceFollowState(deviceId: String) async throws -> Result<UserDeviceFollowState?, NetworkErrorResponse> {
		try await meRepository.getDeviceFollowState(deviceId: deviceId)
	}

	private func resolveAddressLocation(_ location: CLLocationCoordinate2D?) async -> String? {
		guard let location else {
			return nil
		}

		return try? await geocoder.resolveAddressLocation(location)
	}
}
