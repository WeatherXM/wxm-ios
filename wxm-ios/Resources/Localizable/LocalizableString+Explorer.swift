//
//  LocalizableString+Explorer.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 7/5/25.
//

import Foundation

extension LocalizableString {
	enum Explorer {
		case mapLayers
		case mapLayersDefault
		case mapLayersDefaultDescription
		case mapLayersDataQualityScore
		case mapLayersDataQualityScoreDescription
	}
}

extension LocalizableString.Explorer: WXMLocalizable {
	var localized: String {
		var localized = NSLocalizedString(key, comment: "")
		return localized
	}

	var key: String {
		switch self {
			case .mapLayers:
				"explorer_map_layers"
			case .mapLayersDefault:
				"explorer_map_layers_default"
			case .mapLayersDefaultDescription:
				"explorer_map_layers_default_description"
			case .mapLayersDataQualityScore:
				"explorer_map_layers_data_quality_score"
			case .mapLayersDataQualityScoreDescription:
				"explorer_map_layers_data_quality_score_description"
		}
	}
}
