//
//  StationAlertsManager.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 24/7/25.
//

import Foundation
import DomainLayer
import Toolkit

struct StationAlertsManager {
	let meUseCase: MeUseCaseApi

	func checkForStationIssues() async {
		let devices = try? await meUseCase.getOwnedDevices().toAsync().get()
		devices?.forEach {
			checkStation($0)
		}
	}
}

private extension StationAlertsManager {
	func checkStation(_ device: DeviceDetails) {
		var alerts: [StationAlert] = []
		// Is active
		if !device.isActive {
			alerts.append(.inactive)
		}

		// Low battery
		if device.batteryState == .low {
			alerts.append(.battery)
		}
		
		// Firmware
		if device.checkFirmwareIfNeedsUpdate() {
			alerts.append(.firmware)
		}

		// Health
		if let qod = device.qod, qod < 80 {
			alerts.append(.health)
		}

		handleAlerts(for: device, alerts: alerts)
	}

	func handleAlerts(for device: DeviceDetails, alerts: [StationAlert]) {
		let notificationsScheduler = LocalNotificationScheduler()
		alerts.forEach {
			notificationsScheduler.postNotification(id: "\(String(describing: device.id))_\($0)",
													title: $0.notificationTitle,
													body: $0.notificationDescription(for: device.displayName))
		}
	}
}
