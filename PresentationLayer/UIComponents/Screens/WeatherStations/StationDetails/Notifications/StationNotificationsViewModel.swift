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
	@Published var masterSwitchValue: Bool = false

	init(device: DeviceDetails, followState: UserDeviceFollowState, useCase: StationNotificationsUseCaseApi) {
		self.device = device
		self.followState = followState
		self.useCase = useCase
	}

	func valueFor(notificationType: StationNotificationsTypes) -> Bool {
		useCase.isNotificationEnabled(notificationType)
	}

	func setValue(_ value: Bool, for notificationType: StationNotificationsTypes) {
		useCase.setNotificationEnabled(value, for: notificationType)
	}

	func setmasterSwitchValue(_ value: Bool) {
		print(value)
		masterSwitchValue = value
	}
}

extension StationNotificationsViewModel: HashableViewModel {
	nonisolated func hash(into hasher: inout Hasher) {

	}
}
