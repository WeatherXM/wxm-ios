//
//  ClaimDeviceSetFrequencyViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 31/5/24.
//

import Foundation
import DomainLayer
import Toolkit

class ClaimDeviceSetFrequencyViewModel: ObservableObject {
	@Published var selectedFrequency: Frequency?
	@Published var preSelectedFrequency: Frequency = .US915
	@Published var didSelectFrequencyFromLocation = false
	@Published var isFrequencyAcknowledged = false
	@Published var selectedLocation: DeviceLocation?
	let completion: GenericCallback<Frequency>

	init(completion: @escaping GenericCallback<Frequency>) {
		self.completion = completion
	}

	func handleClaimButtonTap() {
		guard let selectedFrequency else {
			return
		}

		self.completion(selectedFrequency)
	}
}
