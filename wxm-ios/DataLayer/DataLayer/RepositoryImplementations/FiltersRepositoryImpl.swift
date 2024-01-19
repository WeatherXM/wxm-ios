//
//  FiltersRepositoryImpl.swift
//  DataLayer
//
//  Created by Pantelis Giazitsis on 15/9/23.
//

import Foundation
import Combine
import DomainLayer

public struct FiltersRepositoryImpl: FiltersRepository {
    private let filtersService: FiltersService

    public init(filtersService: FiltersService) {
        self.filtersService = filtersService
    }

    public func setValue(value: FilterProtocol, for key: String) {
        filtersService.setValue(value: value, for: key)
    }
    
    public func getValue(for key: String) -> FilterProtocol? {
        filtersService.getValue(for: key)
    }

    public func clearValue(key: String) {
        filtersService.clearValue(key: key)
    }

    public func getFiltersPublisher() -> AnyPublisher<FilterValues, Never> {
        filtersService.getFiltersPublisher()
    }
}
