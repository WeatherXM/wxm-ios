//
//  ExplorerFactory.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 9/5/25.
//

import Foundation
import DomainLayer
import MapboxMaps
import UIKit

let EXPLORER_DEVICE_COUNT_KEY = "device_count"
let EXPLORER_ACTIVE_DEVICE_COUNT_KEY = "active_device_count"
let EXPLORER_CELL_INDEX_KEY = "cell_index"
let EXPLORER_CELL_CENTER_KEY = "cell_center"

@MainActor
struct ExplorerFactory {
	let publicHexes: [PublicHex]
	private let fillOpacity = 0.5
	private let fillColor = StyleColor(UIColor(colorEnum: .wxmPrimary))
	private let fillOutlineColor = StyleColor(UIColor.white)


	func generateExplorerData() -> ExplorerData {
		var geoJsonSource = GeoJSONSource(id: "heatmap")
		let featuresCollection = publicHexes.map { publicHex -> MapboxMaps.Feature in
			let coordinates = LocationCoordinate2D(latitude: publicHex.center.lat, longitude: publicHex.center.lon)
			let point = Point(coordinates)
			let geometry = Geometry.point(point)
			var feature = Feature(geometry: geometry)
			var jsonObjectProperty = JSONObject()
			jsonObjectProperty[EXPLORER_DEVICE_COUNT_KEY] = JSONValue(publicHex.deviceCount ?? 0)
			feature.properties = jsonObjectProperty
			return feature
		}
		geoJsonSource.data = .featureCollection(FeatureCollection(features: featuresCollection))

		var totalDevices = 0
		var polygonPoints: [PolygonAnnotation] = []
		var textPoints: [PointAnnotation] = []
		publicHexes.forEach { publicHex in
			totalDevices += publicHex.deviceCount ?? 0
			var ringCords = publicHex.polygon.map { point in
				LocationCoordinate2D(latitude: point.lat, longitude: point.lon)
			}

			/*
			Added an extra coordinate same as its first to fix the flickering issue while zooming
			https://github.com/mapbox/mapbox-maps-ios/issues/1503#issuecomment-1320348728
			 */
			if let firstPolygonPoint = publicHex.polygon.first {
				let coordinate = LocationCoordinate2D(latitude: firstPolygonPoint.lat, longitude: firstPolygonPoint.lon)
				ringCords.append(coordinate)
			}
			let ring = Ring(coordinates: ringCords)
			let polygon = Polygon(outerRing: ring)
			var polygonAnnotation = PolygonAnnotation(id: publicHex.index, polygon: polygon)
			polygonAnnotation.fillColor = fillColor
			polygonAnnotation.fillOpacity = fillOpacity
			polygonAnnotation.fillOutlineColor = fillOutlineColor
			polygonAnnotation.userInfo = [EXPLORER_CELL_CENTER_KEY: CLLocationCoordinate2D(latitude: publicHex.center.lat,
																						   longitude: publicHex.center.lon),
										   EXPLORER_CELL_INDEX_KEY: publicHex.index,
								  EXPLORER_ACTIVE_DEVICE_COUNT_KEY: publicHex.activeDeviceCount ?? 0]
			polygonPoints.append(polygonAnnotation)

			var pointAnnotation = PointAnnotation(point: .init(.init(latitude: publicHex.center.lat, longitude: publicHex.center.lon)))
			if let activeDeviceCount = publicHex.activeDeviceCount, activeDeviceCount > 0 {
				pointAnnotation.textField = "\(activeDeviceCount)"
			}
			textPoints.append(pointAnnotation)
		}


		let explorerData = ExplorerData(totalDevices: totalDevices,
										geoJsonSource: geoJsonSource,
										polygonPoints: polygonPoints,
										textPoints: textPoints)

		return explorerData
	}
}
