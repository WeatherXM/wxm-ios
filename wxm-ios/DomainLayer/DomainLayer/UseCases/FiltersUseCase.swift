//
//  FiltersUseCase.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 15/9/23.
//

import Foundation
import Combine

public struct FiltersUseCase {
    
    let repository: FiltersRepository

    public init(repository: FiltersRepository) {
        self.repository = repository
    }

    public func getFiltersPublisher() -> AnyPublisher<FilterValues, Never> {
        repository.getFiltersPublisher()
    }

    public func saveFilters(filterValues: FilterValues) {
        repository.setValue(value: filterValues.sortBy, for: SortBy.udKey)
        repository.setValue(value: filterValues.filter, for: Filter.udKey)
        repository.setValue(value: filterValues.groupBy, for: GroupBy.udKey)
    }
}
