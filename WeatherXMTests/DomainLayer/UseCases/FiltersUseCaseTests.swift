//
//  FiltersUseCaseTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 10/3/25.
//

import Testing
@testable import DomainLayer

struct FiltersUseCaseTests {
	let repository: MockFiltersRepositoryImpl = .init()
	let useCase: FiltersUseCase

	init() {
		self.useCase = FiltersUseCase(repository: repository)
	}

    @Test func save() {
		let values = FilterValues(sortBy: .dateAdded, filter: .all, groupBy: .noGroup)
		useCase.saveFilters(filterValues: values)
		#expect(repository.getValue(for: SortBy.udKey)?.udValue == SortBy.dateAdded.udValue)
		#expect(repository.getValue(for: Filter.udKey)?.udValue == Filter.all.udValue)
		#expect(repository.getValue(for: GroupBy.udKey)?.udValue == GroupBy.noGroup.udValue)
    }
}
