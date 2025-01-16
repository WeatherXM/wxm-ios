//
//  ClaimDeviceLocationViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 15/5/24.
//

import Foundation
import DomainLayer
import Toolkit

@MainActor
class ClaimDeviceLocationViewModel: ObservableObject {
	@Published var termsAccepted = false
	@Published var selectedLocation: DeviceLocation?
	var canProceed: Bool {
		termsAccepted && selectedLocation != nil
	}
	let locationViewModel: SelectLocationMapViewModel
	let completion: GenericCallback<DeviceLocation>

	init(completion: @escaping GenericCallback<DeviceLocation>) {
		self.completion = completion
		locationViewModel = ViewModelsFactory.getLocationMapViewModel()
		locationViewModel.delegate = self
	}

	func handleConfirmButtonTap() {
		guard let selectedLocation else {
			return
		}
		completion(selectedLocation)
	}
}

extension ClaimDeviceLocationViewModel: SelectLocationMapViewModelDelegate {
	func updatedResolvedLocation(location: DeviceLocation?) {
		self.selectedLocation = location
	}
}
