//
//  MockMainRepositoryImpl.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 10/3/25.
//

import Foundation
@testable import DomainLayer

class MockMainRepositoryImpl {
	private(set) var initialized = false
}

extension MockMainRepositoryImpl: MainRepository {
	func initializeHttpMonitor() {
		self.initialized = true
	}
}
