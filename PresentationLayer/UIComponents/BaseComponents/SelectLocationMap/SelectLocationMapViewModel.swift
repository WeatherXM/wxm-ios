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
import MapboxMaps

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
	@Published private(set) var explorerData: ExplorerData?
	var mapControls: MapControls = .init()
	private var cancellableSet: Set<AnyCancellable> = .init()
	private var latestTask: Cancellable?
	private var latestPointedAnnotations: [PolygonAnnotation]?
	let useCase: DeviceLocationUseCaseApi
	let explorerUseCase: ExplorerUseCaseApi
	weak var delegate: SelectLocationMapViewModelDelegate?
	let linkNavigation: LinkNavigation

	init(useCase: DeviceLocationUseCaseApi,
		 explorerUseCase: ExplorerUseCaseApi,
		 initialCoordinate: CLLocationCoordinate2D? = nil,
		 delegate: SelectLocationMapViewModelDelegate? = nil,
		 linkNavigation: LinkNavigation = LinkNavigationHelper()) {
		self.useCase = useCase
		self.explorerUseCase = explorerUseCase
		self.delegate = delegate
		self.selectedCoordinate = initialCoordinate ?? useCase.getSuggestedDeviceLocation() ?? .init()
		self.linkNavigation = linkNavigation
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

		Task { @MainActor in
			await getExplorerData()
		}
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

	func handlePointedAnnotationsChange(annotations: [PolygonAnnotation]) {
		latestPointedAnnotations = annotations
		let capacityReached = isPointedCellCapaictyReached()
		
		if capacityReached {
			Toast.shared.show(text: LocalizableString.ClaimDevice.cellCapacityReachedMessage.localized.attributedMarkdown ?? "",
							  type: .info,
							  retryButtonTitle: LocalizableString.readMore.localized) { [weak self] in
				self?.linkNavigation.openUrl(DisplayedLinks.cellCapacity.linkURL)
			}
		}
	}

	func isPointedCellCapaictyReached() -> Bool {
		guard let annotation = latestPointedAnnotations?.first,
			  let count = annotation.userInfo?[ExplorerKeys.deviceCount.rawValue] as? Int,
			  let capacity = annotation.userInfo?[ExplorerKeys.cellCapacity.rawValue] as? Int else {
			return false
		}
		return count >= capacity
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

	func getExplorerData() async {
		do {
			let result = try await explorerUseCase.getPublicHexes()
			switch result {
				case .success(let hexes):
					self.explorerData = ExplorerFactory(publicHexes: hexes).generateExplorerData()
				case .failure(let error):
					print(error)
			}
		} catch {
			print(error)
		}
	}
}
