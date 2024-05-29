//
//  SelectDeviceViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 28/5/24.
//

import Foundation
import Toolkit
import DomainLayer

class SelectDeviceViewModel: ObservableObject {
	@Published var isBluetoothReady: Bool = false
	@Published var isScanning: Bool = false
	@Published var bluetoothState: BluetoothState = .unknown
	@Published var devices: [BTWXMDevice] = []
	
	private let useCase: DevicesUseCase

	init(useCase: DevicesUseCase) {
		self.useCase = useCase
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
