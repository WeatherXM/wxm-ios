//
//  MockFiltersRepositoryImpl.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 7/3/25.
//

import Foundation
@testable import DomainLayer
import Combine

class MockFiltersRepositoryImpl {
	private var dictionary: [String: any FilterProtocol] = [:]
	private let filtersSubject: CurrentValueSubject<FilterValues, Never> = .init(FilterValues(sortBy: .defaultValue, filter: .defaultValue, groupBy: .defaultValue))
}

extension MockFiltersRepositoryImpl: FiltersRepository {
	func setValue(value: FilterProtocol, for key: String) {
		dictionary[key] = value
	}
	
	func getValue(for key: String) -> FilterProtocol? {
		dictionary[key]
	}
	
	func clearValue(key: String) {
		dictionary.removeValue(forKey: key)
	}
	
	func getFiltersPublisher() -> AnyPublisher<FilterValues, Never> {
		filtersSubject.eraseToAnyPublisher()
	}
}
