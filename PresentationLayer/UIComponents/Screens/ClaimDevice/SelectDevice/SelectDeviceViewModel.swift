//
//  SelectDeviceViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 28/5/24.
//

import Foundation
import Toolkit
import DomainLayer
import Combine

@MainActor
class SelectDeviceViewModel: ObservableObject {
	let scanDuration: CGFloat = 5.0
	@Published var isBluetoothReady: Bool = false
	@Published var isScanning: Bool = false
	@Published var bluetoothState: BluetoothState = .unknown
	@Published var devices: [BTWXMDevice] = []
	@Published var deviceToConnect: BTWXMDevice?
	let completion: GenericCallback<(BTWXMDevice?, BluetoothHeliumError?)>

	private let useCase: DevicesUseCase
	private var cancellableSet: Set<AnyCancellable> = []

	init(useCase: DevicesUseCase, completion: @escaping GenericCallback<(BTWXMDevice?, BluetoothHeliumError?)>) {
		self.useCase = useCase
		self.completion = completion
	}

	func setup() {
		useCase.enableBluetooth()
		observeBTState()
	}

	func startScanning() {
		isScanning = true
		useCase.startBluetoothScanning()

		DispatchQueue.main.asyncAfter(deadline: .now() + scanDuration) { [weak self] in
			self?.stopScanning()
		}
	}

	func stopScanning() {
		isScanning = false
		useCase.stopBluetoothScanning()
	}

	func handleDeviceTap(_ device: BTWXMDevice) {
		guard deviceToConnect == nil else {
			return
		}

		deviceToConnect = device
		Task { @MainActor in
			let error = await useCase.connect(device: device)
			deviceToConnect = nil
			completion((device, error))
		}
	}

	func handleDebugButtonTap() {
		completion((BTWXMDevice.mock, nil))
	}
}

private extension SelectDeviceViewModel {
	func observeBTState() {
		useCase.bluetoothState.sink { [weak self] state in
			guard let self = self else { return }
			self.bluetoothState = state
			switch state {
				case .unsupported, .unauthorized, .poweredOff, .unknown, .resetting:
					self.isBluetoothReady = false
				case .poweredOn:
					self.isBluetoothReady = true
					self.startScanning()
			}
		}.store(in: &cancellableSet)

		useCase.bluetoothDevices.sink { [weak self] devices in
			guard let self else { return }
			self.devices = devices
		}.store(in: &cancellableSet)

	}
}
