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

enum ExplorerKeys: String {
	case deviceCount = "device_count"
	case cellIndex = "cell_index"
	case cellCenter = "cell_center"
}

@MainActor
struct ExplorerFactory {
	let publicHexes: [PublicHex]
	private let fillOpacity = 0.5
	private let fillColor = StyleColor(UIColor(colorEnum: .explorerPolygon))
	private let fillOutlineColor = StyleColor(UIColor.white)
	private let cellCapacityFillOpacity = 0.2
	private let cellCapacityFillColor = StyleColor(UIColor(colorEnum: .wxmPrimary))
	private let cellCapacityFillOutlineColor = StyleColor(UIColor(colorEnum: .wxmPrimary))
	private let cellCapacityReachedFillColor = StyleColor(UIColor(colorEnum: .error))
	private let cellCapacityReachedFillOutlineColor = StyleColor(UIColor(colorEnum: .error))

	func generateExplorerData() -> ExplorerData {
		var geoJsonSource = GeoJSONSource(id: "heatmap")
		let featuresCollection = publicHexes.map { publicHex -> MapboxMaps.Feature in
			let coordinates = LocationCoordinate2D(latitude: publicHex.center.lat, longitude: publicHex.center.lon)
			let point = Point(coordinates)
			let geometry = Geometry.point(point)
			var feature = Feature(geometry: geometry)
			var jsonObjectProperty = JSONObject()
			jsonObjectProperty[ExplorerKeys.deviceCount.rawValue] = JSONValue(publicHex.deviceCount ?? 0)
			feature.properties = jsonObjectProperty
			return feature
		}
		geoJsonSource.data = .featureCollection(FeatureCollection(features: featuresCollection))

		var totalDevices = 0
		var polygonPoints: [PolygonAnnotation] = []
		var coloredPolygonPoints: [PolygonAnnotation] = []
		var cellCapacityPolygonPoints: [PolygonAnnotation] = []
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
			polygonAnnotation.userInfo = [ExplorerKeys.cellCenter.rawValue: CLLocationCoordinate2D(latitude: publicHex.center.lat,
																								   longitude: publicHex.center.lon),
										  ExplorerKeys.cellIndex.rawValue: publicHex.index,
										  ExplorerKeys.deviceCount.rawValue: publicHex.deviceCount ?? 0]
			polygonPoints.append(polygonAnnotation)
			
			var coloredAnnotation = polygonAnnotation
			coloredAnnotation.fillColor = StyleColor(UIColor(colorEnum: publicHex.averageDataQuality?.rewardScoreColor ?? .darkGrey))
			coloredPolygonPoints.append(coloredAnnotation)

			var cellCapacityAnnotation = polygonAnnotation
			let capacityReached = publicHex.cellCapacityReached
			cellCapacityAnnotation.fillColor = capacityReached ? cellCapacityReachedFillColor : cellCapacityFillColor
			cellCapacityAnnotation.fillOpacity = cellCapacityFillOpacity
			cellCapacityAnnotation.fillOutlineColor = capacityReached ? cellCapacityReachedFillOutlineColor : cellCapacityFillOutlineColor
			cellCapacityPolygonPoints.append(cellCapacityAnnotation)

			var pointAnnotation = PointAnnotation(point: .init(.init(latitude: publicHex.center.lat, longitude: publicHex.center.lon)))
			if let deviceCount = publicHex.deviceCount, deviceCount > 0 {
				pointAnnotation.textField = "\(deviceCount)"
			}
			textPoints.append(pointAnnotation)
		}


		let explorerData = ExplorerData(totalDevices: totalDevices,
										geoJsonSource: geoJsonSource,
										polygonPoints: polygonPoints,
										coloredPolygonPoints: coloredPolygonPoints,
										textPoints: textPoints,
										cellCapacityPoints: cellCapacityPolygonPoints)

		return explorerData
	}
}
