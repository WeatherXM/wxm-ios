//
//  StationNotificationsViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 8/7/25.
//

import Foundation
import DomainLayer
import Toolkit
import Combine

@MainActor
class StationNotificationsViewModel: ObservableObject {
	let device: DeviceDetails
	let followState: UserDeviceFollowState
	let useCase: StationNotificationsUseCaseApi
	@Published private(set) var masterSwitchValue: Bool = false
	@Published private(set) var options: [StationNotificationsTypes: Bool] = [:]
	var availableNotifications: [StationNotificationsTypes] {
		StationNotificationsTypes.casesForDevice(device)
	}
	private var cancellableSet: Set<AnyCancellable> = .init()

	init(device: DeviceDetails, followState: UserDeviceFollowState, useCase: StationNotificationsUseCaseApi) {
		self.device = device
		self.followState = followState
		self.useCase = useCase
		updateOptions()
		updateMasterSwitchValue()
		observeAuthorizationStatus()
	}

	func setValue(_ value: Bool, for notificationType: StationNotificationsTypes) {
		guard let deviceId = device.id else {
			return
		}

		useCase.setNotificationEnabled(value, deviceId: deviceId, for: notificationType)
		updateOptions()
	}

	func setMasterSwitchValue(_ value: Bool) {
		Task { @MainActor in
			let status = await FirebaseManager.shared.gatAuthorizationStatus()
			switch status {
				case .notDetermined:
					try? await FirebaseManager.shared.requestNotificationAuthorization()
				case .authorized:
					if let deviceId = device.id {
						useCase.setNotificationsForDevice(deviceId, enabled: value)
					}
					updateMasterSwitchValue()
				case .denied, .provisional, .ephemeral:
					let title = LocalizableString.Settings.notificationAlertTitle.localized
					let message: LocalizableString.Settings = status == .denied ? .notificationAlertEnableDescription : .notificationAlertDisableDescription
					let alertObj = AlertHelper.AlertObject.getNavigateToSettingsAlert(title: title,
																					  message: message.localized)
					AlertHelper().showAlert(alertObj)
				@unknown default:
					break
			}
		}
	}
}

private extension StationNotificationsViewModel {
	func updateOptions() {
		options = Dictionary(uniqueKeysWithValues: StationNotificationsTypes.casesForDevice(device).map {
			($0, valueFor(notificationType: $0))
		})
	}

	func valueFor(notificationType: StationNotificationsTypes) -> Bool {
		guard let deviceId = device.id else {
			return false
		}

		return useCase.isNotificationEnabled(notificationType, deviceId: deviceId)
	}

	func observeAuthorizationStatus() {
		FirebaseManager.shared
			.notificationsAuthStatusPublisher?
			.receive(on: DispatchQueue.main).sink { [weak self] status in
				self?.updateMasterSwitchValue()
			}.store(in: &cancellableSet)
	}

	func updateMasterSwitchValue() {
		Task { @MainActor in
			let status = await FirebaseManager.shared.gatAuthorizationStatus()
			switch status {
				case .authorized:
					if let deviceId = device.id {
						masterSwitchValue = useCase.areNotificationsEnalbedForDevice(deviceId)
					}
					break
				default:
					masterSwitchValue = false
			}
		}
	}
}

extension StationNotificationsViewModel: HashableViewModel {
	nonisolated func hash(into hasher: inout Hasher) {

	}
}
