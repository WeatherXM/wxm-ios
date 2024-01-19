//
//  Filters.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 15/9/23.
//

import Foundation

public protocol FilterProtocol {
    static var udKey: String { get }
    static var defaultValue: Self { get }
    var udValue: String { get }
}

extension FilterProtocol where Self: CaseIterable {

    public static var defaultValue: Self {
        Self.allCases.first!
    }
}

public enum SortBy: String, CaseIterable, FilterProtocol {
    case dateAdded
    case name
    case lastActive

    public static var udKey: String {
        UserDefaults.GenericKey.sortByDevicesOption.rawValue
    }

    public var udValue: String {
        rawValue
    }
}

public enum Filter: String, CaseIterable, FilterProtocol {
    case all
    case ownedOnly
    case favoritesOnly

    public static var udKey: String {
        UserDefaults.GenericKey.filterDevicesOption.rawValue
    }

    public var udValue: String {
        rawValue
    }
}

public enum GroupBy: String, CaseIterable, FilterProtocol {
    case noGroup
    case relationship
    case status

    public static var udKey: String {
        UserDefaults.GenericKey.groupByDevicesOption.rawValue
    }

    public var udValue: String {
        rawValue
    }
}

public struct FilterValues: Equatable {
    public let sortBy: SortBy
    public let filter: Filter
    public let groupBy: GroupBy

    public static var `default`: FilterValues {
        .init(sortBy: .defaultValue, filter: .defaultValue, groupBy: .defaultValue)
    }

    public init(sortBy: SortBy, filter: Filter, groupBy: GroupBy) {
        self.sortBy = sortBy
        self.filter = filter
        self.groupBy = groupBy
    }
}
