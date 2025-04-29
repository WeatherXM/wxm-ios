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
	func testErrorDescription() {
		#expect(BluetoothState.unsupported.errorDescription == LocalizableString.Bluetooth.unsupportedTitle.localized)
		#expect(BluetoothState.unauthorized.errorDescription == LocalizableString.Bluetooth.noAccessTitle.localized)
		#expect(BluetoothState.poweredOff.errorDescription == LocalizableString.Bluetooth.title.localized)
		#expect(BluetoothState.poweredOn.errorDescription == nil)
		#expect(BluetoothState.unknown.errorDescription == nil)
		#expect(BluetoothState.resetting.errorDescription == nil)
	}

	@Test
	func testPeripheralNotFound() {
		let error = BluetoothHeliumError.peripheralNotFound
		let info = error.uiInfo
		#expect(info.title == LocalizableString.ClaimDevice.failedTitle.localized)
		#expect(info.description == LocalizableString.FirmwareUpdate.stationNotInRangeDescription.localized)
	}

	@Test
	func testConnectionError() {
		let error = BluetoothHeliumError.connectionError
		let info = error.uiInfo
		#expect(info.title == LocalizableString.ClaimDevice.connectionFailedTitle.localized)
		#expect(info.description?.contains(LocalizableString.ClaimDevice.failedTroubleshootingTextLinkTitle.localized) == true)
		#expect(info.description?.contains(LocalizableString.ClaimDevice.failedTextLinkTitle.localized) == true)
	}

	@Test
	func testReboot() {
		let error = BluetoothHeliumError.reboot
		let info = error.uiInfo
		#expect(info.title == LocalizableString.ClaimDevice.connectionFailedTitle.localized)
		#expect(info.description?.contains(LocalizableString.ClaimDevice.failedTroubleshootingTextLinkTitle.localized) == true)
		#expect(info.description?.contains(LocalizableString.ClaimDevice.failedTextLinkTitle.localized) == true)
	}

	@Test
	func testBluetoothState() {
		let error = BluetoothHeliumError.bluetoothState(.unsupported)
		let info = error.uiInfo
		#expect(info.description == LocalizableString.Bluetooth.unsupportedTitle.localized)
	}

	@Test
	func testSetFrequencyWithCode() {
		let error = BluetoothHeliumError.setFrequency(42)
		let info = error.uiInfo
		#expect(info.description?.contains("**42**") == true)
		#expect(info.description?.contains(LocalizableString.ClaimDevice.failedTextLinkTitle.localized) == true)
	}

	@Test
	func testSetFrequencyNilCode() {
		let error = BluetoothHeliumError.setFrequency(nil)
		let info = error.uiInfo
		#expect(info.description?.contains("**-1**") == true)
	}

	@Test
	func testDevEUI() {
		let error = BluetoothHeliumError.devEUI(99)
		let info = error.uiInfo
		#expect(info.description?.contains("**99**") == true)
	}

	@Test
	func testClaimingKey() {
		let error = BluetoothHeliumError.claimingKey(7)
		let info = error.uiInfo
		#expect(info.description?.contains("**7**") == true)
	}

	@Test
	func testUnknown() {
		let error = BluetoothHeliumError.unknown
		let info = error.uiInfo
		#expect(info.title == LocalizableString.ClaimDevice.failedTitle.localized)
		#expect(info.description == LocalizableString.ClaimDevice.errorGeneric.localized)
	}
}
