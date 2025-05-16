//
//  LocalizableString+ExplorerList.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 11/3/24.
//

import Foundation

extension LocalizableString {
	enum ExplorerList {
		case cellCapacity
		case cellCapacityDescription
		case cellNotFoundMessage
		case cellDataQuality
		case cellDataQualityDescription
		case cellDataQualityScore(String)
		case cellNoDataQuality
	}
}

extension LocalizableString.ExplorerList: WXMLocalizable {
	var localized: String {
		var localized = NSLocalizedString(key, comment: "")
		switch self {
			case .cellDataQualityScore(let text):
				localized = String(format: localized, text)
			default: break
		}

		return localized
	}

	var key: String {
		switch self {
			case .cellCapacity:
				return "explorer_list_cell_capacity"
			case .cellCapacityDescription:
				return "explorer_list_cell_capacity_description"
			case .cellNotFoundMessage:
				return "explorer_list_cell_not_found_message"
			case .cellDataQuality:
				return "explorer_list_cell_data_quality"
			case .cellDataQualityDescription:
				return "explorer_list_cell_data_quality_description"
			case .cellDataQualityScore:
				return "explorer_list_cell_data_quality_score"
			case .cellNoDataQuality:
				return "explorer_list_cell_no_data_quality"
		}
	}
}
