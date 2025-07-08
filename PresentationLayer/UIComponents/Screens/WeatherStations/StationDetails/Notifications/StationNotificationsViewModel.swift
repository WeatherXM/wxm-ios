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
	@Published var masterSwitchValue: Bool = false

	init(device: DeviceDetails, followState: UserDeviceFollowState) {
		self.device = device
		self.followState = followState
	}

	func valueFor(notificationType: StationNotificationsTypes) -> Bool {
		true
	}

	func setValue(_ value: Bool, for notificationType: StationNotificationsTypes) {
	}

	func setmasterSwitchValue(_ value: Bool) {
		print(value)
		masterSwitchValue = value
	}
}
