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

protocol SelectStationLocationViewModelDelegate: AnyObject {
	func locationUpdated(with device: DeviceDetails)
}

class SelectStationLocationViewModel: ObservableObject {

	let device: DeviceDetails
	let deviceLocationUseCase: DeviceLocationUseCase
	let meUseCase: MeUseCase
	@Published var termsAccepted: Bool = false
	@Published var selectedCoordinate: CLLocationCoordinate2D
	@Published var searchTerm: String = ""
	@Published private(set) var selectedDeviceLocation: DeviceLocation?
	@Published private(set) var searchResults: [DeviceLocationSearchResult] = []
	@Published var isSuccessful: Bool = false
	private(set) var successObj: FailSuccessStateObject = .emptyObj

	private var latestTask: Cancellable?
	private var cancellableSet: Set<AnyCancellable> = .init()
	private weak var delegate: SelectStationLocationViewModelDelegate?

	init(device: DeviceDetails,
		 deviceLocationUseCase: DeviceLocationUseCase,
		 meUseCase: MeUseCase,
		 delegate: SelectStationLocationViewModelDelegate?) {
		self.device = device
		self.deviceLocationUseCase = deviceLocationUseCase
		self.meUseCase = meUseCase
		self.selectedCoordinate = device.location?.toCLLocationCoordinate2D() ?? .init()
		self.delegate = delegate

		$selectedCoordinate
			.debounce(for: 1.0, scheduler: DispatchQueue.main)
			.sink { [weak self] _ in
				self?.getLocationFromCoordinate()
			}
			.store(in: &cancellableSet)

		$searchTerm
			.debounce(for: 1.0, scheduler: DispatchQueue.main)
			.sink { [weak self] newValue in
				self?.deviceLocationUseCase.searchFor(newValue)
			}
			.store(in: &cancellableSet)

		deviceLocationUseCase.searchResults.sink { [weak self] results in
			self?.searchResults = results
		}.store(in: &cancellableSet)
	}

	func handleConfirmTap() {
		let isValid = deviceLocationUseCase.areLocationCoordinatesValid(LocationCoordinates.fromCLLocationCoordinate2D(selectedCoordinate))
		guard isValid else {
			Toast.shared.show(text: LocalizableString.invalidLocationErrorText.localized.attributedMarkdown ?? "")
			return
		}

		setLocation()
	}

	func handleSearchResultTap(result: DeviceLocationSearchResult) {
		latestTask?.cancel()
		latestTask = deviceLocationUseCase.locationFromSearchResult(result).sink { [weak self] location in
			self?.selectedCoordinate = location.coordinates.toCLLocationCoordinate2D()
		}
	}

	func moveToUserLocation() {
		Task {
			let result = await deviceLocationUseCase.getUserLocation()
			DispatchQueue.main.async {
				switch result {
					case .success(let coordinates):
						self.selectedCoordinate = coordinates
					case .failure(let error):
						switch error {
							case .locationNotFound:
								Toast.shared.show(text: error.description.attributedMarkdown ?? "")
							case .permissionDenied:
								let title = LocalizableString.ClaimDevice.confirmLocationNoAccessToServicesTitle.localized
								let message = LocalizableString.ClaimDevice.confirmLocationNoAccessToServicesText.localized
								let alertObj = AlertHelper.AlertObject.getNavigateToSettingsAlert(title: title,
																								  message: message)
								AlertHelper().showAlert(alertObj)
						}
				}
			}
		}
	}

}

private extension SelectStationLocationViewModel {
	func getLocationFromCoordinate() {
		latestTask?.cancel()
		latestTask = deviceLocationUseCase.locationFromCoordinates(LocationCoordinates.fromCLLocationCoordinate2D(selectedCoordinate)).sink { [weak self] location in
			self?.selectedDeviceLocation = location
		}
	}

	func setLocation() {
		guard let deviceId = device.id else {
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
	func hash(into hasher: inout Hasher) {
		hasher.combine("\(device.id)")
	}
}
