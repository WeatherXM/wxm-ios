//
//  MapBoxClaimDevice.swift
//  PresentationLayer
//
//  Created by Hristos Condrea on 1/6/22.
//

import CoreLocation
import DomainLayer
import Foundation
import MapboxMaps
import SwiftUI
import UIKit
import Toolkit

struct MapBoxClaimDeviceView: View {
	@Binding var location: CLLocationCoordinate2D
	@Binding var annotationTitle: String?
	let geometryProxyForFrameOfMapView: CGRect

	private let markerSize: CGSize = CGSize(width: 44.0, height: 44.0)
	@State private var locationPoint: CGPoint = .zero
	@State private var markerViewSize: CGSize = .zero
	@StateObject private var controls: MapBoxClaimDevice.MapControls = .init()

	init(location: Binding<CLLocationCoordinate2D>,
		 annotationTitle: Binding<String?>,
		 geometryProxyForFrameOfMapView: CGRect) {
		_location = location
		_annotationTitle = annotationTitle
		self.geometryProxyForFrameOfMapView = geometryProxyForFrameOfMapView
	}

	var body: some View {
		ZStack {
			MapBoxClaimDevice(location: $location,
							  locationPoint: $locationPoint,
							  geometryProxyForFrameOfMapView: geometryProxyForFrameOfMapView,
							  controls: controls)

			markerAnnotation
				.offset(x: 0.0, y: markerAnnotationOffset)
				.position(locationPoint)
				.animation(.easeIn, value: annotationTitle)

			Image(asset: .markerDefault)
				.resizable()
				.foregroundColor(Color(colorEnum: .mapPin))
				.frame(width: markerSize.width, height: markerSize.height)
				.offset(x: 0.0, y: -markerSize.height/2.0)
				.position(locationPoint)

			if isRunningOnMac {
				ZoomControls(controlsBottomOffset: .constant(0.0), zoomOutAction: { controls.zoomOutAction?() }, zoomInAction: { controls.zoomInAction?() })
			}
		}
	}

	@ViewBuilder
	private var markerAnnotation: some View {
		if let annotationTitle {
			HStack(spacing: CGFloat(.mediumSpacing)) {
				Image(asset: .globe)
					.renderingMode(.template)
					.foregroundColor(Color(colorEnum: .text))
				
				Text(annotationTitle)
					.font(.system(size: CGFloat(.normalFontSize)))
			}
			.disabled(true)
			.WXMCardStyle()
			.wxmShadow()
		} else {
			EmptyView()
		}
	}

	private var markerAnnotationOffset: CGFloat {
		if geometryProxyForFrameOfMapView.height < 320.0 {
			return markerSize.height/2.0 + CGFloat(.smallSpacing)
		}

		return -(markerSize.height * 3.0 / 2.0 + CGFloat(.smallSpacing))
	}
}

private struct MapBoxClaimDevice: UIViewControllerRepresentable {
    @Binding var location: CLLocationCoordinate2D
	@Binding var locationPoint: CGPoint
    let geometryProxyForFrameOfMapView: CGRect
	@StateObject var controls: MapControls

    func makeUIViewController(context _: Context) -> MapViewLocationController {
		let controller = MapViewLocationController(frame: geometryProxyForFrameOfMapView,
												   location: $location,
												   locationPoint: $locationPoint)

		controls.zoomInAction = { [weak controller] in
			controller?.zoomIn()
		}

		controls.zoomOutAction = { [weak controller] in
			controller?.zoomOut()
		}

		return controller
    }

    func updateUIViewController(_ controller: MapViewLocationController, context _: Context) {
        controller.setCenter(location)
    }
}

extension MapBoxClaimDevice {
	class MapControls: ObservableObject {
		var zoomInAction: VoidCallback?
		var zoomOutAction: VoidCallback?
	}
}

class MapViewLocationController: UIViewController {
    private static let ZOOM_LEVEL: CGFloat = 15

    let frame: CGRect
    @Binding var location: CLLocationCoordinate2D
	@Binding var locationPoint: CGPoint
    internal var mapView: MapView!
	private var cancelablesSet = Set<AnyCancelable>()

    init(frame: CGRect, location: Binding<CLLocationCoordinate2D>, locationPoint: Binding<CGPoint>) {
        self.frame = frame
        _location = location
		_locationPoint = locationPoint
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("fatal Error")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        let cameraOptions = cameraSetup()
        let myMapInitOptions = MapInitOptions(
            cameraOptions: cameraOptions
        )

		mapView = MapView(frame: .zero, mapInitOptions: myMapInitOptions)
        mapView.ornaments.options.logo.margins.y = 30
        mapView.ornaments.options.attributionButton.margins.y = 30
        mapView.ornaments.options.scaleBar.visibility = .hidden
        mapView.gestures.options.rotateEnabled = false
        mapView.gestures.options.pitchEnabled = false
		mapView.mapboxMap.setCamera(to: CameraOptions(zoom: 2))
		
		mapView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(mapView)

		mapView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
		mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
		mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

		mapView.mapboxMap.onMapLoaded.observeNext { [weak self] _ in
			guard let self else {
				return
			}

			self.locationPoint = self.mapView.mapboxMap.point(for: self.location)
		}.store(in: &cancelablesSet)

		self.mapView.mapboxMap.onMapIdle.observe { [weak self] _ in
			guard let self = self else { return }
			let pointAnnotation = PointAnnotation(coordinate: self.mapView.mapboxMap.cameraState.center)
			DispatchQueue.main.async { [weak self] in
				if let self = self {
					self.location = pointAnnotation.point.coordinates
					self.locationPoint = mapView.mapboxMap.point(for: self.location)
				}
			}
		}.store(in: &cancelablesSet)

    }

    func setCenter(_ center: CLLocationCoordinate2D) {
        if mapView.mapboxMap.cameraState.center == center {
            return
        }

        mapView?.mapboxMap.setCamera(to: CameraOptions(center: center, zoom: Self.ZOOM_LEVEL))
    }

	func zoomIn() {
		let zoomLevel = mapView.mapboxMap.cameraState.zoom
		mapView.camera.fly(to: CameraOptions(zoom: zoomLevel + 1))
	}

	func zoomOut() {
		let zoomLevel = mapView.mapboxMap.cameraState.zoom
		mapView.camera.fly(to: CameraOptions(zoom: zoomLevel - 1))
	}

    internal func cameraSetup() -> CameraOptions {
        return CameraOptions(center: CLLocationCoordinate2D())
    }
}

extension MapViewLocationController {
    func locationUpdate(newLocation: Location) {
        mapView.mapboxMap.setCamera(to: CameraOptions(center: newLocation.coordinate, zoom: 13))
        location = newLocation.coordinate
    }
}
