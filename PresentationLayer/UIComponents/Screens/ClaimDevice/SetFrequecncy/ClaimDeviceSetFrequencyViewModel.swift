//
//  ClaimDeviceSetFrequencyViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 31/5/24.
//

import Foundation
import DomainLayer

class ClaimDeviceSetFrequencyViewModel: ObservableObject {
	@Published var selectedFrequency: Frequency?
	@Published var preSelectedFrequency: Frequency = .US915
	@Published var didSelectFrequencyFromLocation = false
	@Published var isFrequencyAcknowledged = false
	@Published var selectedLocation: DeviceLocation?
}
