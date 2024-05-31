//
//  BluetoothState+.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 10/3/23.
//

import DomainLayer

extension BluetoothState {

    var errorDescription: String? {
        switch self {
    
			case .unsupported:
                return LocalizableString.Bluetooth.unsupportedTitle.localized
            case .unauthorized:
                return LocalizableString.Bluetooth.noAccessTitle.localized
            case .poweredOff:
                return LocalizableString.Bluetooth.title.localized
            case .poweredOn, .unknown, .resetting:
                return nil
        }
    }
}

extension BTWXMDevice {
	static var mock: Self {
		BTWXMDevice(identifier: .init(),
					state: .connected,
					name: "Mock device",
					rssi: 0,
					eui: "")
	}
}
