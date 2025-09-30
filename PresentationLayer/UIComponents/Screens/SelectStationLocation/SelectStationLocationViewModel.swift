//
//  SelectStationLocationViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 14/12/23.
//

import Foundation
import DomainLayer
import CoreLocation
import Combine

@MainActor
protocol SelectStationLocationViewModelDelegate: AnyObject {
	func locationUpdated(with device: DeviceDetails)
}

@MainActor
class SelectStationLocationViewModel: ObservableObject {

	let device: DeviceDetails
	let deviceLocationUseCase: DeviceLocationUseCaseApi
	let meUseCase: MeUseCaseApi
	@Published var termsAccepted: Bool = false
	@Published private(set) var selectedCoordinate: CLLocationCoordinate2D?
	@Published var isSuccessful: Bool = false
	private(set) var successObj: FailSuccessStateObject = .emptyObj
	let locationViewModel: SelectLocationMapViewModel

	private var latestTask: Cancellable?
	private var cancellableSet: Set<AnyCancellable> = .init()
	private weak var delegate: SelectStationLocationViewModelDelegate?

	init(device: DeviceDetails,
		 deviceLocationUseCase: DeviceLocationUseCaseApi,
		 meUseCase: MeUseCaseApi,
		 delegate: SelectStationLocationViewModelDelegate?) {
		self.device = device
		self.deviceLocationUseCase = deviceLocationUseCase
		self.meUseCase = meUseCase
		self.locationViewModel = ViewModelsFactory.getLocationMapViewModel(initialCoordinate: device.location?.toCLLocationCoordinate2D())
		self.locationViewModel.delegate = self
		self.delegate = delegate
	}

	func handleConfirmTap() {
		guard let selectedCoordinate,
			  deviceLocationUseCase.areLocationCoordinatesValid(LocationCoordinates.fromCLLocationCoordinate2D(selectedCoordinate)) else {
			Toast.shared.show(text: LocalizableString.invalidLocationErrorText.localized.attributedMarkdown ?? "")
			return
		}

		if locationViewModel.isPointedCellCapacityReached() {
			let okAction: AlertHelper.AlertObject.Action = (LocalizableString.ClaimDevice.relocate.localized, { _ in })
			let obj: AlertHelper.AlertObject = .init(title: LocalizableString.ClaimDevice.cellCapacityReachedAlertTitle.localized,
													 message: LocalizableString.ClaimDevice.cellCapacityReachedMessage.localized,
													 cancelActionTitle: LocalizableString.ClaimDevice.proceedAnyway.localized,
													 cancelAction: { [weak self] in self?.setLocation() },
													 okAction: okAction)

			AlertHelper().showAlert(obj)

			return
		}

		setLocation()
	}
}

extension SelectStationLocationViewModel: SelectLocationMapViewModelDelegate {
	func updatedSelectedCoordinate(coordinate: CLLocationCoordinate2D?) {
		self.selectedCoordinate = coordinate
	}
}

private extension SelectStationLocationViewModel {
	func setLocation() {
		guard let deviceId = device.id, let selectedCoordinate else {
			return
		}

		LoaderView.shared.show()
		do {
			try meUseCase.setDeviceLocationById(deviceId: deviceId, lat: selectedCoordinate.latitude, lon: selectedCoordinate.longitude).sink { [weak self] reslut in
				LoaderView.shared.dismiss {
					switch reslut {
						case .success(let device):
							self?.delegate?.locationUpdated(with: device)
							self?.showSuccess()
						case .failure(let error):
							let info = error.uiInfo
							if let message = info.description?.attributedMarkdown {
								Toast.shared.show(text: message)
							}
					}
				}
			}.store(in: &cancellableSet)
		} catch {
			print(error)
		}
	}

	func showSuccess() {
		let obj = FailSuccessStateObject(type: .editLocation,
										 title: LocalizableString.SelectStationLocation.successTitle.localized,
										 subtitle: LocalizableString.SelectStationLocation.successDescription.localized.attributedMarkdown,
										 cancelTitle: nil,
										 retryTitle: LocalizableString.SelectStationLocation.successButtonTitle.localized,
										 actionButtonsAtTheBottom: true,
										 contactSupportAction: nil,
										 cancelAction: nil) {
			Router.shared.pop()
		}

		successObj = obj
		isSuccessful = true
	}
}

extension SelectStationLocationViewModel: HashableViewModel {
	nonisolated func hash(into hasher: inout Hasher) {
		hasher.combine("\(String(describing: device.id))")
	}
}
