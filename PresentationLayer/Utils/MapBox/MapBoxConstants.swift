//
//  MapBoxConstants.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 13/12/23.
//

import Foundation
import UIKit

enum MapBoxConstants {
	static let mapBoxStyle = Bundle.main.getConfiguration(for: .mapBoxStyle) ?? ""
	static let polygonFillColor = UIColor(red: 51.0/255.0, green: 136.0/255.0, blue: 255.0/255.0, alpha: 0.5)
	static let snapshotSize: CGSize = CGSize(width: 340.0, height: 200.0)
	static let snapshotZoom: CGFloat = 11.0
	static let snapshotMarkerName = "marker"
	static let polygonManagerId = "wtxm-polygon-annotation-manager"
	static let initialLat = 37.98075475244475
	static let initialLon = 23.710478235562956
	static let heatmapLayerId = "wtxm-heatmap-layer"
	static let heatmapSource = "heatmap"
}
