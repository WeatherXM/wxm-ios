//
//  FiltersServiceTest.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 28/1/25.
//

import Testing
@testable import DataLayer
import DomainLayer
import Toolkit

struct FiltersServiceTest {
	private let service: FiltersService
	private var cancellableWrapper: CancellableWrapper

	init() {
		service = FiltersService(cacheManager: MockCacheManager())
		cancellableWrapper = .init()
	}

    @Test func getInitialValue() {
		let sortBy = service.getValue(for: SortBy.udKey)
		#expect(sortBy == nil)

		let filter = service.getValue(for: Filter.udKey)
		#expect(filter == nil)

		let groupBy = service.getValue(for: GroupBy.udKey)
		#expect(groupBy == nil)
    }

	@Test func setValues() {
		service.setValue(value: SortBy.lastActive, for: SortBy.udKey)
		let sortBy = service.getValue(for: SortBy.udKey) as? SortBy
		#expect(sortBy == SortBy.lastActive)

		service.setValue(value: Filter.ownedOnly, for: Filter.udKey)
		let filter = service.getValue(for: Filter.udKey) as? Filter
		#expect(filter == Filter.ownedOnly)

		service.setValue(value: GroupBy.relationship, for: GroupBy.udKey)
		let groupBy = service.getValue(for: GroupBy.udKey) as? GroupBy
		#expect(groupBy == GroupBy.relationship)
	}

	@Test func getInitialValuesFromPublisher() async {
		await confirmation { confirm in
			service.getFiltersPublisher()
				.sink(receiveCompletion: { _ in }) { filters in
					#expect(filters.sortBy == .dateAdded)
					#expect(filters.filter == .all)
					#expect(filters.groupBy == .noGroup)
					confirm()
				}.store(in: &cancellableWrapper.cancellableSet)
		}
	}

	@Test func getValueChangesFromPublisher() async {
		await confirmation { confirm in
			service.getFiltersPublisher()
				.dropFirst()
				.sink(receiveCompletion: { _ in }) { filters in
					#expect(filters.sortBy == .name)
					#expect(filters.filter == .all)
					#expect(filters.groupBy == .noGroup)
					confirm()
				}.store(in: &cancellableWrapper.cancellableSet)
			service.setValue(value: SortBy.name, for: SortBy.udKey)
		}
	}

}
