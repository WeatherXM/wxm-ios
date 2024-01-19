//
//  FiltersRepository.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 15/9/23.
//

import Foundation
import Combine

public protocol FiltersRepository {
    func setValue(value: FilterProtocol, for key: String)
    func getValue(for key: String) -> FilterProtocol?
    func clearValue(key: String)
    func getFiltersPublisher() -> AnyPublisher<FilterValues, Never>
}
