//
//  MapBoxMapView.swift
//  PresentationLayer
//
//  Created by Hristos Condrea on 12/5/22.
//

import CoreLocation
import DomainLayer
import Foundation
import MapboxMaps
import Network
import SwiftUI
import UIKit
import Toolkit
import Combine

struct MapBoxMapView: View {
	@EnvironmentObject var explorerViewModel: ExplorerViewModel

	var body: some View {
		ZStack {
			MapBoxMap()
				.ignoresSafeArea()

			if isRunningOnMac {
				ZoomControls(zoomOutAction: { explorerViewModel.handleZoomOut() },
							 zoomInAction: { explorerViewModel.handleZoomIn() })
			}
		}
	}
}

extension MapBoxMapView {
	struct SnapLocation {
		static let DEFAULT_SNAP_ZOOM_LEVEL: CGFloat = 11

		let coordinates: CLLocationCoordinate2D
		var zoomLevel: CGFloat? = DEFAULT_SNAP_ZOOM_LEVEL
	}
}

#Preview {
	MapBoxMapView()
		.environmentObject(ViewModelsFactory.getExplorerViewModel())
}

private struct MapBoxMap: UIViewControllerRepresentable {
    @EnvironmentObject var explorerViewModel: ExplorerViewModel
	private var canellables: CancellableWrapper = .init()

    func makeUIViewController(context: Context) -> MapViewController {
        let mapViewController = explorerViewModel.mapController ?? MapViewController()
        mapViewController.delegate = context.coordinator
        explorerViewModel.mapController = mapViewController
		observeSnapLocation()

        return mapViewController
    }

	func observeSnapLocation() {
		explorerViewModel.snapLocationPublisher.receive(on: DispatchQueue.main).sink { location in
			guard let location else {
				return
			}
			explorerViewModel.mapController?.snapToLocationCoordinates(location) {}
		}.store(in: &canellables.cancellableSet)
	}

    func updateUIViewController(_ mapViewController: MapViewController, context _: Context) {
        if explorerViewModel.showUserLocation {
            mapViewController.showUserLocation()
        }

		mapViewController.visibleLayer = explorerViewModel.layerOption
    }
}

extension MapBoxMap {
    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: explorerViewModel)
    }

	@MainActor class Coordinator: NSObject, MapViewControllerDelegate {
		private var canellableSet: Set<AnyCancellable> = .init()

        func didTapAnnotation(_: MapViewController, _ annotations: [PolygonAnnotation]) {
            guard let firstValidAnnotation = annotations.first,
				  let hexIndex = firstValidAnnotation.userInfo?[ExplorerKeys.cellIndex.rawValue] as? String else {
				return
			}
            
			viewModel.routeToDeviceListFor(hexIndex, firstValidAnnotation.polygon.center)
        }

        func didTapMapArea(_: MapViewController) {
            viewModel.showTopOfMapItems.toggle()
        }

		func didChangeVisibleBounds(_ mapViewController: MapViewController, bounds: CoordinateBounds) {
			viewModel.didUpdateMapBounds(bounds: bounds)
		}

        func configureMap(_ mapViewController: MapViewController) {
            viewModel.fetchExplorerData()
        }

        let viewModel: ExplorerViewModel

        init(viewModel: ExplorerViewModel) {
            self.viewModel = viewModel
			super.init()
			viewModel.$explorerData.sink { [weak self] data in
				self?.viewModel.mapController?.configureHeatMapLayer(source: data.geoJsonSource)
				self?.viewModel.mapController?.configurePolygonLayer(polygonAnnotations: data.polygonPoints,
																	 coloredPolygonAnnotations: data.coloredPolygonPoints,
																	 pointAnnotations: data.textPoints)
				self?.viewModel.snapToInitialLocation()
			}.store(in: &canellableSet)
        }
    }
}

class MapViewController: UIViewController {
    private static let SNAP_ANIMATION_DURATION: CGFloat = 1.4
	private var cancelablesSet = Set<AnyCancelable>()

	internal var mapView: MapView!
	internal var layer = HeatmapLayer(id: MapBoxConstants.heatmapLayerId,
									  source: MapBoxConstants.heatmapSource)
    internal weak var polygonManager: PolygonAnnotationManager?
	internal weak var coloredPolygonManager: PolygonAnnotationManager?
	internal weak var pointManager: PointAnnotationManager?

    weak var delegate: MapViewControllerDelegate?
	var visibleLayer: ExplorerLayerPickerView.Option = .density {
		didSet {
			updateVisbileLayer()
		}
	}
	private var visiblePolygonManager: PolygonAnnotationManager? {
		switch visibleLayer {
			case .density:
				polygonManager
			case .dataQuality:
				coloredPolygonManager
		}
	}

    @objc func didTapMap(_ tap: UITapGestureRecognizer) {
        handleMapTap(tap)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

		let myMapInitOptions = MapInitOptions(styleURI: MapBoxConstants.styleURI)
	
		mapView = MapView(frame: .zero, mapInitOptions: myMapInitOptions)
        mapView.ornaments.options.scaleBar.visibility = .hidden
        mapView.gestures.options.rotateEnabled = false
        mapView.gestures.options.pitchEnabled = false
        mapView.gestures.singleTapGestureRecognizer.addTarget(self, action: #selector(didTapMap(_:)))
		mapView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(mapView)
		mapView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
		mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
		mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

		mapView.mapboxMap.onMapLoaded.observeNext { [weak self] _ in
            guard let self = self else { return }
            self.cameraSetup()
		}.store(in: &cancelablesSet)

		mapView.mapboxMap.onMapIdle.observe { [weak self] _ in
			guard let self else {
				return
			}

			let cameraOptions = CameraOptions(cameraState: self.mapView.mapboxMap.cameraState)
			let visibleBounds = self.mapView.mapboxMap.coordinateBoundsUnwrapped(for: cameraOptions)
			self.delegate?.didChangeVisibleBounds(self, bounds: visibleBounds)
		}.store(in: &cancelablesSet)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        delegate?.configureMap(self)
    }

    internal func configureHeatMapLayer(source: GeoJSONSource) {
        layer.maxZoom = 10
        layer.heatmapColor = .expression(
            Exp(.interpolate) {
                Exp(.linear)
                Exp(.heatmapDensity)
                0
                UIColor(red: 33.0 / 255.0, green: 102.0 / 255.0, blue: 172.0 / 255.0, alpha: 0.0)
                0.2
                UIColor(red: 103.0 / 255.0, green: 169.0 / 255.0, blue: 207.0 / 255.0, alpha: 1.0)
                0.4
                UIColor(red: 162.0 / 255.0, green: 187.0 / 255.0, blue: 201.0 / 255.0, alpha: 1.0)
                0.6
                UIColor(red: 149.0 / 255.0, green: 153.0 / 255.0, blue: 189.0 / 255.0, alpha: 1.0)
                0.8
                UIColor(red: 103.0 / 255.0, green: 118.0 / 255.0, blue: 247.0 / 255.0, alpha: 1.0)
                1
                UIColor(red: 0.0 / 255.0, green: 255.0 / 255.0, blue: 206.0 / 255.0, alpha: 1.0)
            }
        )
        layer.heatmapWeight = .expression(
            Exp(.interpolate) {
                Exp(.linear)
                Exp(.get) {
                    "device_count"
                }
                0
                0
                100
                100
            }
        )
        layer.heatmapRadius = .expression(
            Exp(.interpolate) {
                Exp(.linear)
                Exp(.zoom)
                0.0
                2
                9.0
                20
            }
        )
        layer.heatmapOpacity = .expression(
            Exp(.interpolate) {
                Exp(.exponential) {
                    0.5
                }
                Exp(.zoom)
                0.0
                1.0
                8.0
                0.9
                9.0
                0.5
                9.5
                0.1
                10.0
                0.0
            }
        )
        do {
            try mapView.mapboxMap.addSource(source)
            try mapView.mapboxMap.addLayer(layer)
        } catch {
            print(error)
        }
    }

	internal func configurePolygonLayer(polygonAnnotations: [PolygonAnnotation],
										coloredPolygonAnnotations: [PolygonAnnotation],
										pointAnnotations: [PointAnnotation]) {
		let polygonAnnotationManager = self.polygonManager ?? mapView.annotations.makePolygonAnnotationManager(id: MapBoxConstants.polygonManagerId)
		polygonAnnotationManager.annotations = polygonAnnotations
		polygonManager = polygonAnnotationManager

		let coloredPolygonManager = self.coloredPolygonManager ?? mapView.annotations.makePolygonAnnotationManager(id: MapBoxConstants.coloredPolygonManagerId)
		coloredPolygonManager.annotations = coloredPolygonAnnotations
		self.coloredPolygonManager = coloredPolygonManager

		let pointAnnotationManager = self.pointManager ?? mapView.annotations.makePointAnnotationManager(id: MapBoxConstants.pointManagerId)
		pointAnnotationManager.annotations = pointAnnotations
		pointManager = pointAnnotationManager
		try? mapView.mapboxMap.updateLayer(withId: MapBoxConstants.pointManagerId, type: SymbolLayer.self) { layer in
			layer.minZoom = 10

			let stops: [Double: Double] = [
				10: CGFloat(.mediumFontSize),
				12: CGFloat(.XLTitleFontSize),
				16: CGFloat(.maxFontSize)
			]

			layer.textSize = .expression(Exp(.interpolate) {
				Exp(.exponential) { 1.75 }
				Exp(.zoom)
				stops
			})
			layer.textColor = .constant(StyleColor(UIColor(colorEnum: .textWhite)))
		}

		updateVisbileLayer()
    }

    internal func cameraSetup() {
		let centerCoordinate = CLLocationCoordinate2D(latitude: MapBoxConstants.initialLat,
													  longitude: MapBoxConstants.initialLon)
        let camera = CameraOptions(center: centerCoordinate, zoom: 1)
        mapView.mapboxMap.setCamera(to: camera)
    }

	func snapToLocationCoordinates(_ snapLocation: MapBoxMapView.SnapLocation, completion: @escaping VoidCallback) {
		mapView.camera.fly(to: CameraOptions(center: snapLocation.coordinates, zoom: snapLocation.zoomLevel), duration: Self.SNAP_ANIMATION_DURATION) { _ in
            completion()
        }
    }

	func zoomIn() {
		let zoomLevel = mapView.mapboxMap.cameraState.zoom
		mapView.camera.fly(to: CameraOptions(zoom: zoomLevel + 1))
	}

	func zoomOut() {
		let zoomLevel = mapView.mapboxMap.cameraState.zoom
		mapView.camera.fly(to: CameraOptions(zoom: zoomLevel - 1))
	}

    func showUserLocation() {
        mapView?.location.options.puckType = .puck2D()
    }

    private func handleMapTap(_ tap: UITapGestureRecognizer) {
		guard let polygonManager = visiblePolygonManager else { return }
        let layerIds = [polygonManager.layerId]
        let annotations = polygonManager.annotations
        let options = RenderedQueryOptions(layerIds: layerIds, filter: nil)
        let point = tap.location(in: tap.view)
		mapView.mapboxMap.queryRenderedFeatures(with: CGRect(origin: point, size: CGSize.zero).insetBy(dx: -20.0, dy: -20.0), options: options) { result in
			switch result {
				case let .success(queriedFeatures):
					
					// Get the identifiers of all the queried features
					let queriedFeatureIds: [String] = queriedFeatures.compactMap {
						guard case let .string(featureId) = $0.queriedFeature.feature.identifier else {
							return nil
						}
						return featureId
					}
					let tappedAnnotations = annotations.filter { queriedFeatureIds.contains($0.id) }
					if tappedAnnotations.isEmpty {
						self.delegate?.didTapMapArea(self)
						return
					}
					self.delegate?.didTapAnnotation(self, tappedAnnotations)
				case .failure:
					self.delegate?.didTapMapArea(self)
			}
		}
	}

	private func updateVisbileLayer() {
		try? mapView.mapboxMap.updateLayer(withId: MapBoxConstants.polygonManagerId, type: FillLayer.self) { layer in
			switch visibleLayer {
				case .density:
					layer.visibility = .constant(.visible)
				case .dataQuality:
					layer.visibility = .constant(.none)
			}
		}

		try? mapView.mapboxMap.updateLayer(withId: MapBoxConstants.coloredPolygonManagerId, type: FillLayer.self) { layer in
			switch visibleLayer {
				case .density:
					layer.visibility = .constant(.none)
				case .dataQuality:
					layer.visibility = .constant(.visible)
			}
		}
	}
}

@MainActor
protocol MapViewControllerDelegate: AnyObject {
	func configureMap(_ mapViewController: MapViewController)
	func didTapAnnotation(_ mapViewController: MapViewController, _ annotations: [PolygonAnnotation])
	func didTapMapArea(_ mapViewController: MapViewController)
	func didChangeVisibleBounds(_ mapViewController: MapViewController, bounds: CoordinateBounds)
}
