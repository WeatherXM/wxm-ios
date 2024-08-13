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

	func testMsToKmH() throws {
		let expectedResults: [Double: Double] = [-10.0: -36,
												  -1.0: -3.6,
												  0.0: 0.0,
												  1.0: 3.6,
												  5.0: 18.0,
												  10.8: 38.88,
												  100.0: 360.0,
												  1000.0: 3600.0]

		expectedResults.forEach { ms, kmh in
			let result =  unitsConverter.msToKmh(ms: ms)
			XCTAssert(result == kmh, "The result is \(result), it should be \(kmh) for \(ms)")
		}
	}

	func testMsToMph() throws {
		let expectedResults: [Double: Double] = [-10.0: -22.37,
												  -1.0: -2.237,
												  0.0: 0.0,
												  1.0: 2.237,
												  5.0: 11.185,
												  10.8: 24.1596,
												  100.0: 223.7,
												  1000.0: 2237.0]

		expectedResults.forEach { ms, mph in
			let result =  unitsConverter.msToMph(ms: ms).rounded(toPlaces: 10)
			XCTAssert(result == mph, "The result is \(result), it should be \(mph) for \(ms)")
		}
	}

	func testMsToKnots() throws {
		let expectedResults: [Double: Double] = [-10.0: -19.44,
												  -1.0: -1.944,
												  0.0: 0.0,
												  1.0: 1.944,
												  5.0: 9.72,
												  10.8: 20.9952,
												  100.0: 194.4,
												  1000.0: 1944]

		expectedResults.forEach { ms, knots in
			let result =  unitsConverter.msToKnots(ms: ms).rounded(toPlaces: 10)
			XCTAssert(result == knots, "The result is \(result), it should be \(knots) for \(ms)")
		}
	}

	func testMsToBeaufort() throws {
		let expectedResults: [Double: Int] = [-10.0: 0,
											   -1.0: 0,
											   0.0: 0,
											   1.0: 1,
											   3.3: 3,
											   5.0: 3,
											   10.8: 6,
											   24.7: 10,
											   100.0: 12,
											   12421.0: 12]

		expectedResults.forEach { ms, beaufort in
			let result =  unitsConverter.msToBeaufort(ms: ms)
			XCTAssert(result == beaufort, "The result is \(result), it should be \(beaufort) for \(ms)")
		}
	}

	func testDegreesToCardinal() throws {
		let expectedResults: [Int: String] = [-10: "-",
											   -2: "-",
											   0: "N",
											   2: "N",
											   23: "NNE",
											   30: "NNE",
											   35: "NE",
											   45: "NE",
											   52: "NE",
											   61: "ENE",
											   70: "ENE",
											   82: "E",
											   95: "E",
											   102: "ESE",
											   120: "ESE",
											   131: "SE",
											   143: "SE",
											   158: "SSE",
											   163: "SSE",
											   174: "S",
											   190: "S",
											   199: "SSW",
											   210: "SSW",
											   230: "SW",
											   255: "WSW",
											   271: "W",
											   286: "WNW",
											   301: "WNW",
											   320: "NW",
											   345: "NNW",
											   360: "N",
											   400: "NE",
											   450: "E"]

		expectedResults.forEach { degrees, cardinal in
			let result = unitsConverter.degreesToCardinal(value: degrees)
			XCTAssert(result == cardinal, "The result is \(result), it should be \(cardinal) for \(degrees)")
		}
	}

}
