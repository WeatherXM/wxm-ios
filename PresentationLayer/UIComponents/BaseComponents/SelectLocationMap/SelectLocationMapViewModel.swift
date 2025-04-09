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
import Toolkit

@MainActor
protocol SelectLocationMapViewModelDelegate: AnyObject {
	func updatedResolvedLocation(location: DeviceLocation?)
	func updatedSelectedCoordinate(coordinate: CLLocationCoordinate2D?)
}

// Make protocol functions optional
extension SelectLocationMapViewModelDelegate {
	func updatedResolvedLocation(location: DeviceLocation?) {}
	func updatedSelectedCoordinate(coordinate: CLLocationCoordinate2D?) {}
}

@MainActor
class SelectLocationMapViewModel: ObservableObject {
	@Published var selectedCoordinate: CLLocationCoordinate2D {
		didSet {
			delegate?.updatedSelectedCoordinate(coordinate: selectedCoordinate)
		}
	}
	@Published private(set) var selectedDeviceLocation: DeviceLocation? {
		didSet {
			delegate?.updatedResolvedLocation(location: selectedDeviceLocation)
		}
	}
	@Published var searchTerm: String = ""
	@Published var showSearchResults: Bool = false {
		didSet {
			guard showSearchResults else { return }
			WXMAnalytics.shared.trackEvent(.userAction, parameters: [.actionName: .searchLocation])
		}
	}
	@Published private(set) var searchResults: [DeviceLocationSearchResult] = []
	var mapControls: MapControls = .init()
	private var cancellableSet: Set<AnyCancellable> = .init()
	private var latestTask: Cancellable?
	let useCase: DeviceLocationUseCaseApi
	weak var delegate: SelectLocationMapViewModelDelegate?

	init(useCase: DeviceLocationUseCaseApi, initialCoordinate: CLLocationCoordinate2D? = nil, delegate: SelectLocationMapViewModelDelegate? = nil) {
		self.useCase = useCase
		self.delegate = delegate
		self.selectedCoordinate = initialCoordinate ?? useCase.getSuggestedDeviceLocation() ?? .init()
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
			self?.mapControls.setMapCenter?(location.coordinates.toCLLocationCoordinate2D())
		}
	}

	func moveToUserLocation() {
		Task { [weak self] in
			guard let self else {
				return
			}

			let result = await self.useCase.getUserLocation()
			DispatchQueue.main.async {
				switch result {
					case .success(let coordinates):
						self.mapControls.setMapCenter?(coordinates)
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
		print("selectedCoordinate: \(selectedCoordinate)" )
		latestTask = useCase.locationFromCoordinates(LocationCoordinates.fromCLLocationCoordinate2D(selectedCoordinate)).sink { [weak self] location in
			print("selectedDeviceLocation: \(String(describing: location?.coordinates))" )
			self?.selectedDeviceLocation = location
		}
	}
}
