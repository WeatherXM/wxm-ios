//
//  StationNotificationsViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 8/7/25.
//

import Foundation
import DomainLayer

class StationNotificationsViewModel: ObservableObject {
	let device: DeviceDetails
	let followState: UserDeviceFollowState
	let useCase: StationNotificationsUseCaseApi
	@Published private(set) var masterSwitchValue: Bool = false
	@Published private(set) var options: [StationNotificationsTypes: Bool] = [:]

	init(device: DeviceDetails, followState: UserDeviceFollowState, useCase: StationNotificationsUseCaseApi) {
		self.device = device
		self.followState = followState
		self.useCase = useCase
		updateOptions()
	}

	func setValue(_ value: Bool, for notificationType: StationNotificationsTypes) {
		useCase.setNotificationEnabled(value, for: notificationType)
		updateOptions()
	}

	func setmasterSwitchValue(_ value: Bool) {
		masterSwitchValue = value
	}
}

private extension StationNotificationsViewModel {
	func updateOptions() {
		options = Dictionary(uniqueKeysWithValues: StationNotificationsTypes.allCases.map {
			($0, valueFor(notificationType: $0))
		})
	}

	func valueFor(notificationType: StationNotificationsTypes) -> Bool {
		useCase.isNotificationEnabled(notificationType)
	}
}

extension StationNotificationsViewModel: HashableViewModel {
	nonisolated func hash(into hasher: inout Hasher) {

	}
}
