//
//  ExplorerData.swift
//  wxm-ios
//
//  Created by Lampros Zouloumis on 17/8/22.
//

import MapboxMaps

public struct ExplorerData: Equatable {
	public static func == (lhs: ExplorerData, rhs: ExplorerData) -> Bool {
		lhs.totalDevices == rhs.totalDevices &&
		lhs.polygonPoints == rhs.polygonPoints
	}

    public let totalDevices: Int
    public let geoJsonSource: GeoJSONSource
    public let polygonPoints: [PolygonAnnotation]
	public let textPoints: [PointAnnotation]

    public init() {
        self.totalDevices = 0
        self.geoJsonSource = GeoJSONSource(id: "heatmap")
        self.polygonPoints = []
		self.textPoints = []
    }

    public init(totalDevices: Int, geoJsonSource: GeoJSONSource, polygonPoints: [PolygonAnnotation], textPoints: [PointAnnotation]) {
        self.totalDevices = totalDevices
        self.geoJsonSource = geoJsonSource
        self.polygonPoints = polygonPoints
		self.textPoints = textPoints
    }
}
