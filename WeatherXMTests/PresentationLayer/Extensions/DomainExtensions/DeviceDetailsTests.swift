//
//  DeviceDetailsTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 29/4/25.
//

import Testing
@testable import WeatherXM
import DomainLayer
import Toolkit

@MainActor
struct DeviceDetailsTests {

	@Test
	func convertedLabel() {
		var device = DeviceDetails.mockDevice
		device.label = "AE:66:F7"
		#expect(device.convertedLabel == "AE66F7")
		device.label = nil
		#expect(device.convertedLabel == nil)
	}

	@Test
	func isActiveStateColorAndTintColor() {
		var device = DeviceDetails.mockDevice
		device.isActive = true
		#expect(device.isActiveStateColor == .success)
		#expect(device.isActiveStateTintColor == .successTint)
		device.isActive = false
		#expect(device.isActiveStateColor == .error)
		#expect(device.isActiveStateTintColor == .errorTint)
	}

	@Test
	func troubleShootingUrl() {
		var device = DeviceDetails.mockDevice
		device.bundle = .mock(name: .m5)
		#expect(device.troubleShootingUrl == DisplayedLinks.m5Troubleshooting.linkURL)
		device.bundle = .mock(name: .h1)
		#expect(device.troubleShootingUrl == DisplayedLinks.heliumTroubleshooting.linkURL)
		device.bundle = .mock(name: .d1)
		#expect(device.troubleShootingUrl == DisplayedLinks.d1Troubleshooting.linkURL)
		device.bundle = .mock(name: .pulse)
		#expect(device.troubleShootingUrl == DisplayedLinks.pulseTroubleshooting.linkURL)
		device.bundle = nil
		#expect(device.troubleShootingUrl == nil)
	}

	@Test
	func explorerUrl() {
		let device = DeviceDetails.mockDevice
		let expected = DisplayedLinks.shareDevice.linkURL + device.name.replacingOccurrences(of: " ", with: "-").lowercased()
		#expect(device.explorerUrl == expected)
	}

	@Test
	func isHelium() {
		var device = DeviceDetails.mockDevice
		device.bundle = .mock(name: .m5)
		#expect(device.isHelium == true)
		device.bundle = .mock(name: .pulse,
							  connectivity: .wifi)
		#expect(device.isHelium == false)
		device.bundle = nil
		#expect(device.isHelium == false)
	}

	@Test
	func testQodStatusColorAndText() {
		var device = DeviceDetails.mockDevice
		device.qod = 80
		#expect(device.qodStatusColor == .success)
		#expect(!device.qodStatusText.isEmpty)
		device.qod = nil
		#expect(device.qodStatusColor == .darkGrey)
		#expect(device.qodStatusText == LocalizableString.Error.noDataTitle.localized)
	}

	@Test
	func testPolStatusColorTextWarningType() {
		var device = DeviceDetails.mockDevice
		device.pol = .verified
		#expect(device.polStatusColor == .success)
		#expect(device.polStatusText == LocalizableString.StationDetails.verified.localized)
		#expect(device.qodWarningType == nil)
		device.pol = .notVerified
		#expect(device.polStatusColor == .warning)
		#expect(device.polStatusText == LocalizableString.StationDetails.notVerified.localized)
		#expect(device.pol?.warningType == .warning)
		device.pol = .noLocation
		#expect(device.polStatusColor == .error)
		#expect(device.polStatusText == LocalizableString.StationDetails.noLocationData.localized)
		#expect(device.pol?.warningType == .error)
		device.pol = nil
		#expect(device.polStatusColor == .darkGrey)
		#expect(device.polStatusText == LocalizableString.StationDetails.pendingVerification.localized)
	}

	@Test
	func testLocationText() {
		var device = DeviceDetails.mockDevice
		device.address = "Test address"
		#expect(device.locationText == "Test address")
		device.address = nil
		#expect(device.locationText == LocalizableString.Error.noLocationDataTitle.localized)
	}

	@Test
	func testIsBatteryLow() {
		var device = DeviceDetails.mockDevice
		let followState = UserDeviceFollowState(deviceId: device.id ?? "", relation: .owned)
		device.batteryState = .low
		#expect(device.isBatteryLow(followState: followState) == true)
		device.batteryState = .ok
		#expect(device.isBatteryLow(followState: followState) == false)
		let notOwned = UserDeviceFollowState(deviceId: device.id ?? "", relation: .followed)
		#expect(device.isBatteryLow(followState: notOwned) == false)
	}

	@Test
	func testNeedsUpdate() {
		var device = DeviceDetails.mockDevice
		let now = Date()
		let persisted = FirmwareVersion(installDate: now, version: "1.0.1")
		// Same version, just installed, should not need update
		#expect(device.needsUpdate(persistedVersion: persisted) == false)
		// Different version, should need update
		let oldPersisted = FirmwareVersion(installDate: now.addingTimeInterval(-3600 * 2), version: "1.0.0")
		#expect(device.needsUpdate(persistedVersion: oldPersisted) == true)
	}

	@Test
	func testCheckFirmwareIfNeedsUpdate() {
		var device = DeviceDetails.mockDevice
		device.bundle = .mock(name: .m5)
		device.firmware = Firmware(assigned: "1.0.2", current: "1.0.1")
		#expect(device.checkFirmwareIfNeedsUpdate() == true)
		device.firmware = Firmware(assigned: "1.0.1", current: "1.0.1")
		#expect(device.checkFirmwareIfNeedsUpdate() == false)
		device.bundle = nil
		#expect(device.checkFirmwareIfNeedsUpdate() == false)
	}

	@Test
	@MainActor
	func testIssues() {
		var device = DeviceDetails.mockDevice
		let mainVM = MainScreenViewModel.shared
		let followState = UserDeviceFollowState(deviceId: device.id ?? "",
												relation: .owned)
		device.isActive = false
		device.batteryState = .low
		device.firmware = Firmware(assigned: "1.0.2", current: "1.0.1")
		let issues = device.issues(mainVM: mainVM, followState: followState)
		#expect(issues.contains(where: { $0.type == .offline }))
		#expect(issues.contains(where: { $0.type == .lowBattery }))
		// If needs update, should also be present
		#expect(issues.contains(where: { $0.type == .needsUpdate }))
	}

	@Test
	@MainActor
	func testHasIssuesAndIssuesCount() {
		var device = DeviceDetails.mockDevice
		let mainVM = MainScreenViewModel.shared
		let followState = UserDeviceFollowState(deviceId: device.id ?? "", relation: .owned)
		device.isActive = false
		#expect(device.hasIssues(mainVM: mainVM, followState: followState) == true)
		#expect(device.issuesCount(mainVM: mainVM, followState: followState) > 0)
		device.isActive = true
		device.batteryState = .ok
		device.firmware = Firmware(assigned: "1.0.1", current: "1.0.1")
		#expect(device.hasIssues(mainVM: mainVM, followState: followState) == false)
		#expect(device.issuesCount(mainVM: mainVM, followState: followState) == 0)
	}

	@Test
	@MainActor
	func testGetIssuesChip() {
		var device = DeviceDetails.mockDevice
		let followState = UserDeviceFollowState(deviceId: device.id ?? "", relation: .owned)
		device.isActive = false
		let chip = device.getIssuesChip(followState: followState)
		#expect(chip != nil)
		#expect(!chip!.title.isEmpty)
	}

	@Test
	@MainActor
	func testOverallWarningType() {
		var device = DeviceDetails.mockDevice
		let mainVM = MainScreenViewModel.shared
		let followState = UserDeviceFollowState(deviceId: device.id ?? "", relation: .owned)
		device.isActive = false
		device.batteryState = .low
		device.firmware = Firmware(assigned: "1.0.2", current: "1.0.1")
		let warningType = device.overallWarningType(mainVM: mainVM, followState: followState)
		#expect(warningType != nil)
	}

	@Test
	func testFirmwareVersionUpdateString() {
		var firmware = Firmware(assigned: "1.0.2", current: "1.0.1")
		#expect(firmware.versionUpdateString == "1.0.1 → 1.0.2")
		firmware = Firmware(assigned: nil, current: "1.0.1")
		#expect(firmware.versionUpdateString == nil)
		firmware = Firmware(assigned: "1.0.2", current: nil)
		#expect(firmware.versionUpdateString == nil)
	}
}
