//
//  ExplorerData.swift
//  DomainLayer
//
//  Created by Lampros Zouloumis on 17/8/22.
//

import struct MapboxMaps.GeoJSONSource
import struct MapboxMaps.PolygonAnnotation

public struct ExplorerData {
    public let totalDevices: Int
    public let geoJsonSource: GeoJSONSource
    public let polygonPoints: [PolygonAnnotation]

    public init() {
        self.totalDevices = 0
        self.geoJsonSource = GeoJSONSource(id: "heatmap")
        self.polygonPoints = []
    }

    public init(totalDevices: Int, geoJsonSource: GeoJSONSource, polygonPoints: [PolygonAnnotation]) {
        self.totalDevices = totalDevices
        self.geoJsonSource = geoJsonSource
        self.polygonPoints = polygonPoints
    }
}
