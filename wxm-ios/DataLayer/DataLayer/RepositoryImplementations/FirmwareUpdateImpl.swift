//
//  FirmwareUpdateImpl.swift
//  DataLayer
//
//  Created by Pantelis Giazitsis on 1/2/23.
//

import Combine
import DomainLayer
import Foundation

public class FirmwareUpdateImpl {
	private let stateSubject = CurrentValueSubject<FirmwareUpdateState, Never>(.unknown)
	private var cancellableSet: Set<AnyCancellable> = []
	private var updater: FirmwareUpdater?
	private let btManager = BluetoothManager()

	/// Keep a ref on continuation of `downloadZipFile` function to avoid leaks in case of cancel download process
	private var downloadFileContinuation: CheckedContinuation<URL?, Error>?
	private var downloadFileCancellable: AnyCancellable?

	public init() {}
}

extension FirmwareUpdateImpl: FirmwareUpdateRepository {
	public var state: AnyPublisher<DomainLayer.BluetoothState, Never> {
		btManager.state
	}

	public var devices: AnyPublisher<[DomainLayer.BTWXMDevice], Never> {
		btManager.devices
	}

	public func enableBluetooth() {
		btManager.enable()
	}

	public func startScanning() {
		btManager.startScanning()
	}

	public func stopScanning() {
		btManager.stopScanning()
	}

	public func updateFirmware(for device: DomainLayer.BTWXMDevice, deviceId: String) -> AnyPublisher<DomainLayer.FirmwareUpdateState, Never> {
		Task {
			stateSubject.send(.connecting)
			guard await connect(device: device) else {
				stateSubject.send(.error(.connection))
				return
			}

			// Start downloading file
			stateSubject.send(.downloading)
			guard let fileUrl = try? await downloadZipFile(deviceId: deviceId) else {
				stateSubject.send(.error(.downloadFile))
				return
			}

			// Connect to BT device and start installing firmware
			updater = FirmwareUpdater(fileUrl: fileUrl, btDevice: device)
			updater?.start()

			// Attach an observer to monitor update changes and propagate
			observeUpdaterState(for: fileUrl)
		}
		return stateSubject.eraseToAnyPublisher()
	}

	public func stopFirmwareUpdate() {
		updater?.stop()
		downloadFileCancellable?.cancel()
		downloadFileContinuation?.resume(returning: nil)
		downloadFileContinuation = nil
	}
}

private extension FirmwareUpdateImpl {
	func downloadZipFile(deviceId: String) async throws -> URL? {
		let urlRequest = try MeApiRequestBuilder.getDeviceFirmwareById(deviceId: deviceId).asURLRequest()

		return try await withCheckedThrowingContinuation { [weak self] continuation in
			guard let self,
				  let destinationUrl = getFileDestinationUrl(deviceId: deviceId)
			else {
				continuation.resume(returning: nil)
				return
			}

			self.downloadFileContinuation = continuation
			self.downloadFileCancellable = ApiClient.shared.downloadFile(urlRequest, destinationFileUrl: destinationUrl).sink { response in
				self.downloadFileContinuation = nil
				if let error = response.error {
					continuation.resume(throwing: error)
				} else {
					continuation.resume(returning: response.fileURL)
				}
			}
		}
	}

	func connect(device: DomainLayer.BTWXMDevice) async -> Bool {
		return await withCheckedContinuation { [weak self] continuation in
			self?.btManager.connect(to: device) { error in
				if error == nil {
					continuation.resume(returning: true)
					return
				}

				continuation.resume(returning: false)
			}
		}
	}

	func getFileDestinationUrl(deviceId: String) -> URL? {
		guard let documentsURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
			return nil
		}

		let fileUrl = documentsURL.appendingPathComponent("\(deviceId).zip")

		return fileUrl
	}

	func observeUpdaterState(for fileUrl: URL) {
		updater?.state.sink { [weak self] state in
			switch state {
				case .idle:
					self?.stateSubject.send(.unknown)
				case .connecting, .starting:
					/// Ignore this case since is supposed the peripheral is already connected
					/// from the first step of the flow
					break
				case let .progress(progress):
					self?.stateSubject.send(.installing(progress: progress))
				case .completed:
					self?.stateSubject.send(.finished)
					// Remove file after operation finished
					try? FileManager.default.removeItem(at: fileUrl)
				case let .aborted(errorMessage):
					self?.stateSubject.send(.error(.installation(errorMessage)))
					// Remove file after operation finished
					try? FileManager.default.removeItem(at: fileUrl)
			}
		}.store(in: &cancellableSet)
	}
}
