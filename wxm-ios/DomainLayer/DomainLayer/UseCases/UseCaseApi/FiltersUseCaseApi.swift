//
//  FiltersUseCaseApi.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 1/4/25.
//

import Combine

public protocol FiltersUseCaseApi: Sendable {
	func getFiltersPublisher() -> AnyPublisher<FilterValues, Never>
	func saveFilters(filterValues: FilterValues)
}
