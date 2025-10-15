//
//  MapBoxConstants.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 13/12/23.
//

import Foundation
import UIKit
import MapboxMaps

enum MapBoxConstants {
	static let polygonFillColor = UIColor(red: 51.0/255.0, green: 136.0/255.0, blue: 255.0/255.0, alpha: 0.5)
	static let snapshotSize: CGSize = CGSize(width: 340.0, height: 200.0)
	static let snapshotZoom: CGFloat = 11.0
	static let snapshotMarkerName = "marker"
	static let polygonManagerId = "wtxm-polygon-annotation-manager"
	static let coloredPolygonManagerId = "wtxm-colored-polygon-annotation-manager"
	static let cellCapacityPolygonManagerId = "wtxm-cell-capacity-polygon-annotation-manager"
	static let initialLat = 37.98075475244475
	static let initialLon = 23.710478235562956
	static let heatmapLayerId = "wtxm-heatmap-layer"
	static let pointManagerId = "wtxm-point-annotation-manager"
	static let bordersManagerId = "wtxm-borders-annotation-manager"
	static let heatmapSource = "heatmap"
	static let customData = "custom_data"

	static var styleURI: StyleURI {
		guard let style: String = Bundle.main.getConfiguration(for: .mapBoxStyle) else {
			return .standard
		}

		return StyleURI(rawValue: style) ?? .standard
	}

	static var styleURL: URL? {
		guard let style: String = Bundle.main.getConfiguration(for: .mapBoxStyle) else {
			return nil
		}

		return URL(string: style)
	}
}
