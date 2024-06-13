//
//  MapBoxSnapshotUrlGenerator.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 13/12/23.
//

import Foundation
import MapboxStatic
import CoreLocation
import DomainLayer
import UIKit

struct MapBoxSnapshotUrlGenerator {
	let options: Options

	func getUrl() -> URL? {
		guard let styleUrl = MapBoxConstants.styleURL,
			  let accessToken: String = Bundle.main.getConfiguration(for: .mapBoxAccessToken) else {
			return nil
		}

		let camera = SnapshotCamera(lookingAtCenter: options.location, zoomLevel: options.zoomLevel)
		let snapshotOptions = SnapshotOptions(styleURL: styleUrl, camera: camera, size: options.size)
		snapshotOptions.showsLogo = false
		snapshotOptions.showsAttribution = false
		
		var overlays: [Overlay] = []

		if let polygon = options.polygon {
			let path = Path(coordinates: polygon)
			path.fillColor = MapBoxConstants.polygonFillColor
			overlays.append(path)
		}

		if let markerLocation = options.markerLocation {
			let marker = Marker(coordinate: markerLocation, size: .small, iconName: MapBoxConstants.snapshotMarkerName)
			marker.label = nil
			marker.color = UIColor(colorEnum: .primary)
			overlays.append(marker)
		}

		snapshotOptions.overlays = overlays

		let snapshot = Snapshot(options: snapshotOptions, accessToken: accessToken)

		return snapshot.url
	}
}

extension MapBoxSnapshotUrlGenerator {
	struct Options {
		let location: CLLocationCoordinate2D
		let markerLocation: CLLocationCoordinate2D?
		let size: CGSize
		let zoomLevel: CGFloat
		let polygon: [CLLocationCoordinate2D]?
	}
}
