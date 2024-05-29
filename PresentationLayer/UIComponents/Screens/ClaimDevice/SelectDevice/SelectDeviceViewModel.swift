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

class SelectDeviceViewModel: ObservableObject {
	@Published var isBluetoothReady: Bool = false
	@Published var isScanning: Bool = false
	@Published var bluetoothState: BluetoothState = .unknown
	@Published var devices: [BTWXMDevice] = []
	
	private let useCase: DevicesUseCase
	private var cancellableSet: Set<AnyCancellable> = []

	init(useCase: DevicesUseCase) {
		self.useCase = useCase
		useCase.enableBluetooth()
		observeBTState()
	}

	func startScanning() {
		isScanning = true
		useCase.startBluetoothScanning()
	}

	func stopScanning() {
		isScanning = false
		useCase.stopBluetoothScanning()
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

	}
}
