//
//  ExplorerData.swift
//  wxm-ios
//
//  Created by Lampros Zouloumis on 17/8/22.
//

import MapboxMaps

struct ExplorerData: Equatable {
	public static func == (lhs: ExplorerData, rhs: ExplorerData) -> Bool {
		lhs.totalDevices == rhs.totalDevices &&
		lhs.polygonPoints == rhs.polygonPoints &&
		lhs.coloredPolygonPoints == rhs.coloredPolygonPoints &&
		lhs.geoJsonSource.id == rhs.geoJsonSource.id
	}

    let totalDevices: Int
    let geoJsonSource: GeoJSONSource
    let polygonPoints: [PolygonAnnotation]
	let coloredPolygonPoints: [PolygonAnnotation]
	let textPoints: [PointAnnotation]
	let cellCapacityPoints: [PolygonAnnotation]
	let cellBorderPoints: [PolylineAnnotation]
	let	cellCapacityTextPoints: [PointAnnotation]

    init() {
        self.totalDevices = 0
        self.geoJsonSource = GeoJSONSource(id: "heatmap")
        self.polygonPoints = []
		self.coloredPolygonPoints = []
		self.textPoints = []
		self.cellCapacityPoints = []
		self.cellBorderPoints = []
		self.cellCapacityTextPoints = []
    }

    init(totalDevices: Int,
		 geoJsonSource: GeoJSONSource,
		 polygonPoints: [PolygonAnnotation],
		 coloredPolygonPoints: [PolygonAnnotation],
		 textPoints: [PointAnnotation],
		 cellCapacityPoints: [PolygonAnnotation],
		 cellBorderPoints: [PolylineAnnotation],
		 cellCapacityTextPoints: [PointAnnotation]
	) {
        self.totalDevices = totalDevices
        self.geoJsonSource = geoJsonSource
        self.polygonPoints = polygonPoints
		self.coloredPolygonPoints = coloredPolygonPoints
		self.textPoints = textPoints
		self.cellCapacityPoints = cellCapacityPoints
		self.cellBorderPoints = cellBorderPoints
		self.cellCapacityTextPoints = cellCapacityTextPoints
    }
}
