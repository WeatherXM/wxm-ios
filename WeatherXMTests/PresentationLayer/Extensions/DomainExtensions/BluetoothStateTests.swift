//
//  BluetoothStateTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 29/4/25.
//

import Testing
@testable import WeatherXM
import DomainLayer

struct BluetoothStateTests {

	@Test
	func errorDescription() {
		#expect(BluetoothState.unsupported.errorDescription == LocalizableString.Bluetooth.unsupportedTitle.localized)
		#expect(BluetoothState.unauthorized.errorDescription == LocalizableString.Bluetooth.noAccessTitle.localized)
		#expect(BluetoothState.poweredOff.errorDescription == LocalizableString.Bluetooth.title.localized)
		#expect(BluetoothState.poweredOn.errorDescription == nil)
		#expect(BluetoothState.unknown.errorDescription == nil)
		#expect(BluetoothState.resetting.errorDescription == nil)
	}

	@Test
	func peripheralNotFound() {
		let error = BluetoothHeliumError.peripheralNotFound
		let info = error.uiInfo
		#expect(info.title == LocalizableString.ClaimDevice.failedTitle.localized)
		#expect(info.description == LocalizableString.FirmwareUpdate.stationNotInRangeDescription.localized)
	}

	@Test
	func connectionError() {
		let error = BluetoothHeliumError.connectionError
		let info = error.uiInfo
		#expect(info.title == LocalizableString.ClaimDevice.connectionFailedTitle.localized)
		#expect(info.description?.contains(LocalizableString.ClaimDevice.failedTroubleshootingTextLinkTitle.localized) == true)
		#expect(info.description?.contains(LocalizableString.ClaimDevice.failedTextLinkTitle.localized) == true)
	}

	@Test
	func reboot() {
		let error = BluetoothHeliumError.reboot
		let info = error.uiInfo
		#expect(info.title == LocalizableString.ClaimDevice.connectionFailedTitle.localized)
		#expect(info.description?.contains(LocalizableString.ClaimDevice.failedTroubleshootingTextLinkTitle.localized) == true)
		#expect(info.description?.contains(LocalizableString.ClaimDevice.failedTextLinkTitle.localized) == true)
	}

	@Test
	func bluetoothState() {
		let error = BluetoothHeliumError.bluetoothState(.unsupported)
		let info = error.uiInfo
		#expect(info.description == LocalizableString.Bluetooth.unsupportedTitle.localized)
	}

	@Test
	func setFrequencyWithCode() {
		let error = BluetoothHeliumError.setFrequency(42)
		let info = error.uiInfo
		#expect(info.description?.contains("**42**") == true)
		#expect(info.description?.contains(LocalizableString.ClaimDevice.failedTextLinkTitle.localized) == true)
	}

	@Test
	func setFrequencyNilCode() {
		let error = BluetoothHeliumError.setFrequency(nil)
		let info = error.uiInfo
		#expect(info.title == LocalizableString.ClaimDevice.failedTitle.localized)
		#expect(info.description?.contains("**-1**") == true)
		#expect(info.description?.contains(LocalizableString.ClaimDevice.failedTextLinkTitle.localized) == true)
	}

	@Test
	func devEUI() {
		let error = BluetoothHeliumError.devEUI(99)
		let info = error.uiInfo
		#expect(info.title == LocalizableString.ClaimDevice.failedTitle.localized)
		#expect(info.description?.contains("**99**") == true)
		#expect(info.description?.contains(LocalizableString.ClaimDevice.failedTextLinkTitle.localized) == true)
	}

	@Test
	func claimingKey() {
		let error = BluetoothHeliumError.claimingKey(7)
		let info = error.uiInfo
		#expect(info.title == LocalizableString.ClaimDevice.failedTitle.localized)
		#expect(info.description?.contains("**7**") == true)
		#expect(info.description?.contains(LocalizableString.ClaimDevice.failedTextLinkTitle.localized) == true)
	}

	@Test
	func unknown() {
		let error = BluetoothHeliumError.unknown
		let info = error.uiInfo
		#expect(info.title == LocalizableString.ClaimDevice.failedTitle.localized)
		#expect(info.description == LocalizableString.ClaimDevice.errorGeneric.localized)
	}
}
