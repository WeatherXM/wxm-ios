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

public final class ExplorerViewModel: ObservableObject {
    private final let explorerUseCase: ExplorerUseCase
    /// Keep a ref in map controller in order to persist  and show
    /// the same instance between rerenders
    var mapController: MapViewController?

    public init(explorerUseCase: ExplorerUseCase) {
        self.explorerUseCase = explorerUseCase
    }

    @Published var showTopOfMapItems: Bool = false

    @Published var isLoading: Bool = false
    @Published var isSearchActive: Bool = false
	@Published var explorerData: ExplorerData = ExplorerData()

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
		isLoading = true
		explorerUseCase.getPublicHexes { [weak self] result in
			guard let self else {
				return
			}

			self.isLoading = false
			switch result {
				case let .success(explorerData):
					guard self.explorerData != explorerData else {
						return
					}

					self.explorerData = explorerData
				case let .failure(error):
					print(error)
					switch error {
						case .infrastructure, .serialization:
							if let message = LocalizableString.Error.genericMessage.localized.attributedMarkdown {
								Toast.shared.show(text: message)
							}
						case .networkRelated(let neworkError):
							if let message = neworkError?.uiInfo.description?.attributedMarkdown {
								Toast.shared.show(text: message)
							}
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
