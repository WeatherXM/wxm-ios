//
//  ExplorerViewModel.swift
//  PresentationLayer
//
//  Created by Hristos Condrea on 17/5/22.
//

import Combine
import CoreLocation
import DomainLayer
import Toolkit
import MapboxMaps

@MainActor
public final class ExplorerViewModel: ObservableObject {
	private final let explorerUseCase: ExplorerUseCaseApi
    /// Keep a ref in map controller in order to persist  and show
    /// the same instance between rerenders
    var mapController: MapViewController?

	public init(explorerUseCase: ExplorerUseCaseApi) {
        self.explorerUseCase = explorerUseCase
    }

    @Published var showTopOfMapItems: Bool = false

    @Published var isLoading: Bool = false
    @Published var isSearchActive: Bool = false
	@Published var explorerData: ExplorerData = ExplorerData()
	@Published var layerOption: ExplorerLayerPickerView.Option = .default
	@Published var showLayerPicker: Bool = false

	lazy var snapLocationPublisher: AnyPublisher<MapBoxMapView.SnapLocation?, Never> = snapLocationSubject.eraseToAnyPublisher()
	private let snapLocationSubject = PassthroughSubject<MapBoxMapView.SnapLocation?, Never>()
    @Published var showUserLocation: Bool = false
	private var isInitialSnapped: Bool = false

    private(set) lazy var searchViewModel = {
        let vm = ViewModelsFactory.getNetworkSearchViewModel()
        vm.delegate = self
        return vm
    }()

	func fetchExplorerData() {
		Task { @MainActor in
			isLoading = true
			defer {
				self.isLoading = false
			}
			
			do {
				let result = try await explorerUseCase.getPublicHexes()
				switch result {
					case .success(let publicHexes):
						let factory = ExplorerFactory(publicHexes: publicHexes)
						let explorerData = factory.generateExplorerData()
						guard self.explorerData != explorerData else {
							return
						}
						self.explorerData = explorerData
					case .failure(let error):
						if let message = error.uiInfo.description?.attributedMarkdown {
							Toast.shared.show(text: message)
						}
				}
			} catch {
				print(error)
				if let message = LocalizableString.Error.genericMessage.localized.attributedMarkdown {
					Toast.shared.show(text: message)
				}
			}
		}
	}

    func routeToDeviceListFor(_ hexIndex: String, _ coordinates: CLLocationCoordinate2D?) {
        if let coordinates {
            let route = Route.explorerList(ViewModelsFactory.getExplorerStationsListViewModel(cellIndex: hexIndex, cellCenter: coordinates))
            Router.shared.navigateTo(route)
        }
    }

    func userLocationButtonTapped() {
        WXMAnalytics.shared.trackEvent(.userAction, parameters: [.actionName: .myLocation])
        handleUserLocationTap()
    }

	func layersButtonTapped() {
		showLayerPicker = true
	}
	
	func snapToInitialLocation() {
		guard !isInitialSnapped else {
			return
		}
		isInitialSnapped = true

		let status = explorerUseCase.userLocationAuthorizationStatus
		switch status {
			case .authorized:
				Task {
					await snapToUserLocation(zoomEnabled: false)
				}
			default:
				if let suggestedLocation = explorerUseCase.getSuggestedDeviceLocation() {
					let locationToSnap = MapBoxMapView.SnapLocation(coordinates: suggestedLocation, zoomLevel: nil)
					snapLocationSubject.send(locationToSnap)
				}
		}
	}

	func handleZoomIn() {
		mapController?.zoomIn()
	}

	func handleZoomOut() {
		mapController?.zoomOut()
	}

	func didUpdateMapBounds(bounds: CoordinateBounds) {
		let count = explorerData.polygonPoints.reduce(0) {
			guard let center = $1.polygon.center,
				  case let isInBounds = bounds.containsLatitude(forLatitude: center.latitude) && bounds.containsLongitude(forLongitude: center.longitude),
				  let count = $1.userInfo?[ExplorerKeys.deviceCount.rawValue] as? Int else {
				return $0
			}

			let sum = $0 + (isInBounds ? count : 0)
			return sum
		}

		searchViewModel.updateStations(count: count)
	}
}

private extension ExplorerViewModel {

    func handleUserLocationTap() {
        WXMAnalytics.shared.trackEvent(.userAction, parameters: [.actionName: .myLocation])
        Task {
			await snapToUserLocation()
        }
    }

    func navigateToDeviceDetails(deviceId: String, cellIndex: String, cellCenter: CLLocationCoordinate2D?) {
        let route = Route.stationDetails(ViewModelsFactory.getStationDetailsViewModel(deviceId: deviceId, cellIndex: cellIndex, cellCenter: cellCenter))
        Router.shared.navigateTo(route)
    }

	func snapToUserLocation(zoomEnabled: Bool = true) async {
		let result = await explorerUseCase.getUserLocation()
		DispatchQueue.main.async {
			switch result {
				case .success(let coordinates):
					let zoomLevel: CGFloat? = zoomEnabled ? MapBoxMapView.SnapLocation.DEFAULT_SNAP_ZOOM_LEVEL : nil
					let locationToSnap = MapBoxMapView.SnapLocation(coordinates: coordinates, zoomLevel: zoomLevel)
					self.snapLocationSubject.send(locationToSnap)
					self.showUserLocation = true
				case .failure(let error):
					print(error)
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

extension ExplorerViewModel: ExplorerSearchViewModelDelegate {
    func settingsButtonTapped() {
        Router.shared.navigateTo(.settings(ViewModelsFactory.getSettingsViewModel(userId: "")))
    }

	func networkStatisticsTapped() {
		Router.shared.navigateTo(.netStats(ViewModelsFactory.getNetworkStatsViewModel()))
	}

    func rowTapped(coordinates: CLLocationCoordinate2D, deviceId: String?, cellIndex: String?) {
		let locationToSnap = MapBoxMapView.SnapLocation(coordinates: coordinates)
		snapLocationSubject.send(locationToSnap)

        if let deviceId, let cellIndex {
            navigateToDeviceDetails(deviceId: deviceId, cellIndex: cellIndex, cellCenter: coordinates)
        }
    }

    func searchWillBecomeActive(_ active: Bool) {
        DispatchQueue.main.async {
            self.isSearchActive = active
        }
    }
}
