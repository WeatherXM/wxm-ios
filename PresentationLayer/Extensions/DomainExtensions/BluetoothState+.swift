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

extension BluetoothHeliumError {
	struct UIInfo {
		let title: String
		let description: String?
	}
	
	var uiInfo: UIInfo {
		var title =	LocalizableString.ClaimDevice.failedTitle.localized
		var description: String? = LocalizableString.ClaimDevice.errorGeneric.localized
		
		switch self {
			case .peripheralNotFound:
				description = LocalizableString.FirmwareUpdate.stationNotInRangeDescription.localized
			case .connectionError, .reboot:
				title = LocalizableString.ClaimDevice.connectionFailedTitle.localized
				let contactLink = LocalizableString.ClaimDevice.failedTextLinkTitle.localized
				let troubleshootingLink = LocalizableString.ClaimDevice.failedTroubleshootingTextLinkTitle.localized
				description = LocalizableString.ClaimDevice.connectionFailedMarkDownText(troubleshootingLink, contactLink).localized
			case .bluetoothState(let bluetoothState):
				description = bluetoothState.errorDescription
			case .setFrequency(let code), .devEUI(let code), .claimingKey(let code):
				let contactLink = LocalizableString.ClaimDevice.failedTextLinkTitle.localized
				let error = "**\(code ?? -1)**"
				description = LocalizableString.ClaimDevice.failedText(error, contactLink).localized
			case .unknown:
				break
		}
		
		return UIInfo(title: title, description: description)
	}
	
}
