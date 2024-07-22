//
//  UnitsConverterTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 22/7/24.
//

import XCTest
@testable import Toolkit

final class UnitsConverterTests: XCTestCase {

	let unitsConverter: UnitsConverter = .init()

	func testTemperature() throws {
		let expectedResults: [Double: Double] = [-10.0: 14.0,
												  -1.0: 30.2,
												  0.0: 32.0,
												  1.0: 33.8,
												  5.0: 41.0,
												  10.8: 51.44,
												  30.0: 86.0,
												  40.29: 104.522,
												  .greatestFiniteMagnitude: .infinity]

		expectedResults.forEach { celsius, fahrenheit in
			let result = unitsConverter.celsiusToFahrenheit(celsius: celsius)
			XCTAssert(result == fahrenheit, "The result is \(result), it should be \(fahrenheit) for \(celsius)")
		}
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
