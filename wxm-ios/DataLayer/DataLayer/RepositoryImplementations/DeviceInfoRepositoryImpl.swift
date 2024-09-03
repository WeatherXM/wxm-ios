//
//  DeviceInfoRepositoryImpl.swift
//  DataLayer
//
//  Created by Pantelis Giazitsis on 8/3/23.
//

import Foundation
import DomainLayer
import Combine
import Alamofire

public class DeviceInfoRepositoryImpl: DeviceInfoRepository {
	private lazy var bluetoothWrapper: BTActionWrapper = BTActionWrapper()
	private var canellables: Set<AnyCancellable> = []
	private let userDevicesService: UserDevicesService

	public init(userDevicesService: UserDevicesService) {
		self.userDevicesService = userDevicesService
	}
}

extension DeviceInfoRepositoryImpl {
	public func getDeviceInfo(deviceId: String) throws -> AnyPublisher<DataResponse<NetworkDevicesInfoResponse, NetworkErrorResponse>, Never> {
		let builder = MeApiRequestBuilder.getUserDeviceInfoById(deviceId: deviceId)
		let urlRequest = try builder.asURLRequest()
		return ApiClient.shared.requestCodableAuthorized(urlRequest, mockFileName: builder.mockFileName)
	}

	public func setFriendlyName(deviceId: String, name: String) throws -> AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never> {
		try userDevicesService.setFriendlyName(deviceId: deviceId, name: name)
	}

	public func deleteFriendlyName(deviceId: String) throws -> AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never> {
		try userDevicesService.deleteFriendlyName(deviceId: deviceId)
	}

	public func disclaimDevice(serialNumber: String) throws -> AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never> {
		try userDevicesService.disclaimDevice(serialNumber: serialNumber)
	}

	public func rebootStation(device: DeviceDetails) -> AnyPublisher<RebootStationState, Never> {
		let valueSubject = CurrentValueSubject<RebootStationState, Never>(.connect)
		Task {
			valueSubject.send(.connect)
			if let error = await bluetoothWrapper.connect(device: device) {
				valueSubject.send(.failed(error.toRebootError))
				return
			}

			valueSubject.send(.rebooting)
			if let error = await bluetoothWrapper.reboot(device: device) {
				valueSubject.send(.failed(error.toRebootError))
				return
			}
			valueSubject.send(.finished)
		}

		return valueSubject.eraseToAnyPublisher()
	}

	public func changeFrequency(device: DeviceDetails, frequency: Frequency) -> AnyPublisher<ChangeFrequencyState, Never> {
		let valueSubject = CurrentValueSubject<ChangeFrequencyState, Never>(.connect)
		Task {
			valueSubject.send(.connect)
			if let error = await bluetoothWrapper.connect(device: device) {
				valueSubject.send(.failed(error.toChangeFrequencyError))
				return
			}

			valueSubject.send(.changing)
			if let error = await bluetoothWrapper.setFrequency(device: device, frequency: frequency) {
				valueSubject.send(.failed(error.toChangeFrequencyError))
				return
			}
			valueSubject.send(.finished)
		}

		return valueSubject.eraseToAnyPublisher()
	}
}

extension BTActionWrapper.ActionError {
	var toRebootError: RebootError {
		switch self {
			case .bluetoothState(let bluetoothState):
				return .bluetooth(bluetoothState)
			case .reboot:
				return .connect
			case .notInRange:
				return .notInRange
			case .connect:
				return .connect
			case .unknown, .setFrequency, .fetchClaimingKey, .fetchDevEUI:
				return .unknown
		}
	}

	var toChangeFrequencyError: ChangeFrequencyError {
		switch self {
			case .bluetoothState(let bluetoothState):
				return .bluetooth(bluetoothState)
			case .reboot:
				return .connect
			case .notInRange:
				return .notInRange
			case .connect:
				return .connect
			case .setFrequency(let commandError):
				return .settingFrequency("\(commandError?.errorCode ?? -1)")
			case .unknown, .fetchClaimingKey, .fetchDevEUI:
				return .unknown
		}
	}

	var toBluetoothError: BluetoothHeliumError {
		switch self {
			case .bluetoothState(let state):
					.bluetoothState(state)
			case .reboot:
					.reboot
			case .notInRange:
					.peripheralNotFound
			case .connect:
					.connectionError
			case .setFrequency(let commandError):
					.setFrequency(commandError?.errorCode)
			case .fetchClaimingKey(let commandError):
					.claimingKey(commandError?.errorCode)
			case .fetchDevEUI(let commandError):
					.devEUI(commandError?.errorCode)
			case .unknown:
					.unknown
		}
	}
}
