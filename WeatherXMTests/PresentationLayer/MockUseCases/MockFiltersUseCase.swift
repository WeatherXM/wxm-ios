//
//  MockFiltersUseCase.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 3/4/25.
//

import DomainLayer
@preconcurrency import Combine

final class MockFiltersUseCase: FiltersUseCaseApi {
	private let filtersSubject: CurrentValueSubject<FilterValues, Never> = .init(FilterValues(sortBy: .defaultValue, filter: .defaultValue, groupBy: .defaultValue))
	nonisolated(unsafe) private var dictionary: [String: any FilterProtocol] = [:]

	func getFiltersPublisher() -> AnyPublisher<FilterValues, Never> {
		filtersSubject.eraseToAnyPublisher()
	}
	
	func saveFilters(filterValues: FilterValues) {
		dictionary[SortBy.udKey] = filterValues.sortBy
		dictionary[Filter.udKey] = filterValues.filter
		dictionary[GroupBy.udKey] = filterValues.groupBy
	}
}
