//
//  Filters+.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 15/9/23.
//

import DomainLayer
import Toolkit

protocol FilterPresentable: CustomStringConvertible where Self: CaseIterable {
    static var title: String { get }
    var analyticsParameterValue: ParameterValue { get }
}

extension GroupBy: @retroactive CustomStringConvertible {}
extension GroupBy: FilterPresentable {
    static var title: String {
        LocalizableString.Filters.groupByTitle.localized
    }
    
    public var description: String {
        switch self {
            case .noGroup:
                LocalizableString.Filters.groupByNoGrouping.localized
            case .relationship:
                LocalizableString.Filters.groupByRelationship.localized
            case .status:
                LocalizableString.Filters.groupByStatus.localized
        }
    }
    
    var analyticsParameterValue: ParameterValue {
        switch self {
            case .noGroup:
                    .noGrouping
            case .relationship:
                    .relationship
            case .status:
                    .status
        }
    }
}

extension SortBy: @retroactive CustomStringConvertible {}
extension SortBy: FilterPresentable {
    static var title: String {
        LocalizableString.Filters.sortByTitle.localized
    }
    
    public var description: String {
        switch self {
            case .dateAdded:
                LocalizableString.Filters.sortByDateAdded.localized
            case .name:
                LocalizableString.Filters.sortByName.localized
            case .lastActive:
                LocalizableString.Filters.sortByLastActive.localized
        }
    }
    
    var analyticsParameterValue: ParameterValue {
        switch self {
            case .dateAdded:
                    .dateAdded
            case .name:
                    .name
            case .lastActive:
                    .lastActive
        }
    }
}

extension Filter: @retroactive CustomStringConvertible {}
extension Filter: FilterPresentable {
    static var title: String {
        LocalizableString.Filters.filterTitle.localized
    }
    
    public var description: String {
        switch self {
            case .all:
                LocalizableString.Filters.filterShowAll.localized
            case .ownedOnly:
                LocalizableString.Filters.filterOwnedOnly.localized
            case .favoritesOnly:
                LocalizableString.Filters.filterFavoritesOnly.localized
        }
    }
    
    var analyticsParameterValue: ParameterValue {
        switch self {
            case .all:
                    .all
            case .ownedOnly:
                    .owned
            case .favoritesOnly:
                    .favorites
        }
    }
}
