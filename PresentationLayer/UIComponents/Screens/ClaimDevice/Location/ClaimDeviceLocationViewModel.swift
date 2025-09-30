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

		if locationViewModel.isPointedCellCapacityReached() {
			let okAction: AlertHelper.AlertObject.Action = (LocalizableString.ClaimDevice.proceedAnyway.localized, { [weak self] _ in self?.completion(selectedLocation) })
			let obj: AlertHelper.AlertObject = .init(title: LocalizableString.ClaimDevice.cellCapacityReachedAlertTitle.localized,
													 message: LocalizableString.ClaimDevice.cellCapacityReachedMessage.localized,
													 cancelActionTitle: LocalizableString.ClaimDevice.relocate.localized,
													 cancelAction: {  },
													 okAction: okAction)

			AlertHelper().showAlert(obj)

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
