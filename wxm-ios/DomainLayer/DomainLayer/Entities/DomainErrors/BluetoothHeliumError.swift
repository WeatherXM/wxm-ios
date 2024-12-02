//
//  BluetoothHeliumError.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 30/5/24.
//

import Foundation

public enum BluetoothHeliumError: Error, Sendable {
	case peripheralNotFound
	case connectionError
	case reboot
	case bluetoothState(BluetoothState)
	case setFrequency(Int?)
	case devEUI(Int?)
	case claimingKey(Int?)
	case unknown
}
