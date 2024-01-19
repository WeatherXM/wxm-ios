//
//  LocalizableString+Filters.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 15/9/23.
//

import Foundation

extension LocalizableString {
    enum Filters {
        case reset
        case title
        case sortByTitle
        case sortByDateAdded
        case sortByName
        case sortByLastActive
        case filterTitle
        case filterShowAll
        case filterOwnedOnly
        case filterFavoritesOnly
        case groupByTitle
        case groupByNoGrouping
        case groupByRelationship
        case groupByStatus
    }
}

extension LocalizableString.Filters: WXMLocalizable {
    var localized: String {
        NSLocalizedString(key, comment: "")
    }

    var key: String {
        switch self {
            case .reset:
                return "filters_reset"
            case .title:
                return "filters_title"
            case .sortByTitle:
                return "filters_sort_by_title"
            case .sortByDateAdded:
                return "filters_sort_by_date_added"
            case .sortByName:
                return "filters_sort_by_name"
            case .sortByLastActive:
                return "filters_sort_by_last_active"
            case .filterTitle:
                return "filters_filter_title"
            case .filterShowAll:
                return "filters_filter_show_all"
            case .filterOwnedOnly:
                return "filters_filter_owned_only"
            case .filterFavoritesOnly:
                return "filters_filter_favorites_only"
            case .groupByTitle:
                return "filters_group_by_title"
            case .groupByNoGrouping:
                return "filters_group_by_no_grouping"
            case .groupByRelationship:
                return "filters_group_by_relationship"
            case .groupByStatus:
                return "filters_group_by_status"
        }
    }
}
