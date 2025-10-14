//
//  LocalizableString+Search.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 6/9/23.
//

import Foundation

extension LocalizableString {
    enum Search {
        case fieldPlaceholder
        case resultsRecent
        case noResultsTitle
        case noResultsSubtitle
        case noRecentResultsTitle
        case noRecentResultsSubtitle
        case termLimitMessage(Int)
		case stationsInArea
		case noStationsInArea
    }
}

extension LocalizableString.Search: WXMLocalizable {
    var localized: String {
        var localized = NSLocalizedString(key, comment: "")
        switch self {
            case .termLimitMessage(let count):
                localized = String(format: localized, count)
            default: break
        }

        return localized
    }

    var key: String {
        switch self {
            case .fieldPlaceholder:
                return "search_field_placeholder"
            case .resultsRecent:
                return "search_result_recent"
            case .noResultsTitle:
                return "search_no_results_title"
            case .noResultsSubtitle:
                return "search_no_results_subtitle"
            case .noRecentResultsTitle:
                return "search_no_recent_results_title"
            case .noRecentResultsSubtitle:
                return "search_no_recent_results_subtitle"
            case .termLimitMessage:
                return "search_term_limit_message_format"
			case .stationsInArea:
				return "search_stations_in_area"
			case .noStationsInArea:
				return "search_no_stations_in_area"
        }
    }
}
