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
	@Published var bluetoothState: BluetoothState = .unknown
	@Published var devices: [BTWXMDevice] = []

}
