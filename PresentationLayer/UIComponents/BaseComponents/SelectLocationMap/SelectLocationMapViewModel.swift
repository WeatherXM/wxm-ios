//
//  SelectLocationMapViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 15/5/24.
//

import Foundation
import CoreLocation
import Combine
import DomainLayer

protocol SelectLocationMapViewModelDelegate: AnyObject {
	func updatedSelectedLocation(location: DeviceLocation?)
}

class SelectLocationMapViewModel: ObservableObject {
	@Published var selectedCoordinate: CLLocationCoordinate2D = .init()
	@Published private(set) var selectedDeviceLocation: DeviceLocation? {
		didSet {
			delegate?.updatedSelectedLocation(location: selectedDeviceLocation)
		}
	}
	@Published var searchTerm: String = ""
	@Published private(set) var searchResults: [DeviceLocationSearchResult] = []
	private var cancellableSet: Set<AnyCancellable> = .init()
	private var latestTask: Cancellable?
	let useCase: DeviceLocationUseCase
	weak var delegate: SelectLocationMapViewModelDelegate?

	init(useCase: DeviceLocationUseCase, delegate: SelectLocationMapViewModelDelegate? = nil) {
		self.useCase = useCase
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
				self?.useCase.searchFor(newValue)
			}
			.store(in: &cancellableSet)

		useCase.searchResults.sink { [weak self] results in
			self?.searchResults = results
		}.store(in: &cancellableSet)
	}

	func handleSearchResultTap(result: DeviceLocationSearchResult) {
		latestTask?.cancel()
		latestTask = useCase.locationFromSearchResult(result).sink { [weak self] location in
			self?.selectedCoordinate = location.coordinates.toCLLocationCoordinate2D()
		}
	}

	func moveToUserLocation() {
		Task {
			let result = await useCase.getUserLocation()
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

private extension SelectLocationMapViewModel {
	func getLocationFromCoordinate() {
		latestTask?.cancel()
		latestTask = useCase.locationFromCoordinates(LocationCoordinates.fromCLLocationCoordinate2D(selectedCoordinate)).sink { [weak self] location in
			self?.selectedDeviceLocation = location
		}
	}
}
