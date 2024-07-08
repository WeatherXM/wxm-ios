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
	}
}

extension LocalizableString.ExplorerList: WXMLocalizable {
	var localized: String {
		let localized = NSLocalizedString(key, comment: "")
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
		}
	}
}
