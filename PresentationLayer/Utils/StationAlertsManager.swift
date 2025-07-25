//
//  StationAlertsManager.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 24/7/25.
//

import Foundation
import DomainLayer
import Toolkit
import UserNotifications

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
		if shouldSendInactiveNotification(for: device) {
			alerts.append(.inactive)
		}

		// Low battery
		if shouldSendLowBatteryNotification(for: device) {
			alerts.append(.battery)
		}
		
		// Firmware
		if shouldSendFirmwareNotification(for: device) {
			alerts.append(.firmware)
		}

		// Health
		if shouldSendHealthNotification(for: device) {
			alerts.append(.health)
		}

		handleAlerts(for: device, alerts: alerts)
	}

	func handleAlerts(for device: DeviceDetails, alerts: [StationAlert]) {
		guard let deviceId = device.id else {
			return
		}

		let notificationsScheduler = LocalNotificationScheduler()
		alerts.forEach {
			let userInfo = [UNNotificationResponse.typeKey: UNNotificationResponse.stationVal,
							UNNotificationResponse.deviceIdKey: deviceId]
			notificationsScheduler.postNotification(id: "\(String(describing: device.id))_\($0)",
													title: $0.notificationTitle,
													body: $0.notificationDescription(for: device.displayName),
													threadId: deviceId,
													userInfo: userInfo)
			meUseCase.notificationAlertSent(for: deviceId, alert: $0)
		}
	}

	func shouldSendInactiveNotification(for device: DeviceDetails) -> Bool {
		guard let deviceId = device.id,
			  let lastActiveAt = device.lastActiveAt?.timestampToDate() else {
			return false
		}

		var shouldSend: Bool = false
		if let lastNotificationSent = meUseCase.lastNotificationAlertSent(for: deviceId, alert: .inactive) {
			if lastActiveAt > lastNotificationSent {
				shouldSend = true
			} else if lastNotificationSent.isToday {
				shouldSend = false
			}
		}

		return shouldSend && device.isActive == false
	}

	func shouldSendLowBatteryNotification(for device: DeviceDetails) -> Bool {
		guard let deviceId = device.id else {
			return false
		}

		let lastNotificationSent = meUseCase.lastNotificationAlertSent(for: deviceId, alert: .battery)
		if lastNotificationSent?.isToday == true {
			return false
		}

		return device.batteryState == .low
	}

	func shouldSendFirmwareNotification(for device: DeviceDetails) -> Bool {
		guard let deviceId = device.id else {
			return false
		}

		let lastNotificationSent = meUseCase.lastNotificationAlertSent(for: deviceId, alert: .firmware)
		if lastNotificationSent?.isToday == true {
			return false
		}

		return device.checkFirmwareIfNeedsUpdate()
	}

	func shouldSendHealthNotification(for device: DeviceDetails) -> Bool {
		guard let deviceId = device.id,
			  let qod = device.qod,
			  let pol = device.pol,
			  let qodTs = device.latestQodTs,
			  qodTs.isYesterday else {
			return false
		}

		let lastNotificationSent = meUseCase.lastNotificationAlertSent(for: deviceId, alert: .health)
		if lastNotificationSent?.isToday == true {
			return false
		}

		return qod < 80 || pol != .verified
	}
}
