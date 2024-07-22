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

	func testMMtoInches() throws {
		let expectedResults: [Double: Double] = [-10.0: -0.3937007874,
												  -1.0: -0.0393700787,
												  0.0: 0.0,
												  1.0: 0.0393700787,
												  5.0: 0.1968503937,
												  10.8: 0.4251968504,
												  100.0: 3.937007874,
												  1000.0: 39.3700787402]

		expectedResults.forEach { millimeters, inches in
			let result =  unitsConverter.millimetersToInches(mm: millimeters).rounded(toPlaces: 10)
			XCTAssert(result == inches, "The result is \(result), it should be \(inches) for \(millimeters)")
		}
	}

	func testhpaToInHg() throws {
		let expectedResults: [Double: Double] = [-10.0: -0.2953,
												  -1.0: -0.02953,
												  0.0: 0.0,
												  1.0: 0.02953,
												  5.0: 0.14765,
												  10.8: 0.318924,
												  100.0: 2.953,
												  1000.0: 29.53]

		expectedResults.forEach { hpa, inHg in
			let result =  unitsConverter.hpaToInHg(hpa: hpa).rounded(toPlaces: 10)
			XCTAssert(result == inHg, "The result is \(result), it should be \(inHg) for \(hpa)")
		}
	}

}
