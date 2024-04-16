//
//  ForecastDetailsViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 16/4/24.
//

import Foundation
import DomainLayer

class ForecastDetailsViewModel: ObservableObject {
	let device: DeviceDetails
	let followState: UserDeviceFollowState?

	init(device: DeviceDetails, followState: UserDeviceFollowState?) {
		self.device = device
		self.followState = followState
	}
}
