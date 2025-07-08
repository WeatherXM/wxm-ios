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

	init(device: DeviceDetails, followState: UserDeviceFollowState) {
		self.device = device
		self.followState = followState
	}
}
