//
//  FiltersService.swift
//  DataLayer
//
//  Created by Pantelis Giazitsis on 18/9/23.
//

import Foundation
import DomainLayer
import Combine
import Toolkit

public class FiltersService {

	private let cacheManager: PersistCacheManager
    private let filtersSubject: CurrentValueSubject<FilterValues, Never> = .init(FilterValues(sortBy: .defaultValue, filter: .defaultValue, groupBy: .defaultValue))

	public init(cacheManager: PersistCacheManager) {
		self.cacheManager = cacheManager
	}

    public func setValue(value: FilterProtocol, for key: String) {
		cacheManager.save(value: value.udValue, key: key)
        notifyChanges()
    }

    public func getValue(for key: String) -> FilterProtocol? {
        guard let rawValue: String = cacheManager.get(key: key) else {
            return nil
        }

        if let sortBy = SortBy(rawValue: rawValue) {
            return sortBy
        }

        if let filter = Filter(rawValue: rawValue) {
            return filter
        }

        if let groupBy = GroupBy(rawValue: rawValue) {
            return groupBy
        }

        return nil
    }

    public func clearValue(key: String) {
		cacheManager.remove(key: key)
        notifyChanges()
    }

    public func getFiltersPublisher() -> AnyPublisher<FilterValues, Never> {
        notifyChanges()
        return filtersSubject.eraseToAnyPublisher()
    }
}

private extension FiltersService {
    func notifyChanges() {
        let sortBy: SortBy = getValue(for: SortBy.udKey) as? SortBy ?? SortBy.defaultValue
        let filter: Filter = getValue(for: Filter.udKey) as? Filter ?? Filter.defaultValue
        let groupBy: GroupBy = getValue(for: GroupBy.udKey) as? GroupBy ?? GroupBy.defaultValue
        
        let filters: FilterValues = .init(sortBy: sortBy, filter: filter, groupBy: groupBy)
        guard filtersSubject.value != filters else {
            return
        }

        filtersSubject.send(filters)
    }
}
