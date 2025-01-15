//
//  WEIConverterTests.swift
//  WEIConverterTests
//
//  Created by Pantelis Giazitsis on 10/7/24.
//

import XCTest
@testable import Toolkit

final class WEIConverterTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testZero() throws {
		let converter = WEIConverter(value: "0")
		XCTAssertEqual(converter.toEthDecimal, 0)
		XCTAssertEqual(converter.toEthDouble, 0.0)
    }

	func testOneEth() throws {
		let converter = WEIConverter(value: "1000000000000000000")
		XCTAssertEqual(converter.toEthDecimal, 1)
		XCTAssertEqual(converter.toEthDouble, 1.0)
	}

	func testMoreThanOneEth() throws {
		let converter = WEIConverter(value: "1100000000000000001")
		XCTAssertEqual(converter.toEthDecimal, Decimal(string: "1.100000000000000001"))
		XCTAssertEqual(converter.toEthDouble, 1.1)
	}

	func testLessThanOneEth() throws {
		let converter = WEIConverter(value: "100000000000000001")
		XCTAssertEqual(converter.toEthDecimal, Decimal(string: "0.100000000000000001"))
		XCTAssertEqual(converter.toEthDouble, 0.1)
	}

	func testZerosAtMostSignificant() throws {
		let converter = WEIConverter(value: "0000300000000000000")
		XCTAssertEqual(converter.toEthDecimal, Decimal(string: "0.0003"))
		// Since we are not testing the exact precision in Double values,
		// we use accuracy to avoid the issues with Double type precision
		XCTAssertEqual(converter.toEthDouble!, 0.0003, accuracy: 0.0000000000000000001)
	}

	func testEmptyString() throws {
		let converter = WEIConverter(value: "")
		XCTAssertNil(converter.toEthDecimal)
		XCTAssertNil(converter.toEthDouble)
	}

	func testOnlySpacesString() throws {
		let converter = WEIConverter(value: "  ")
		XCTAssertEqual(converter.toEthDecimal, 0.0)
		XCTAssertEqual(converter.toEthDouble, 0.0)
	}

	func testNonDigitsString() throws {
		let converter = WEIConverter(value: "WeatherXM")
		XCTAssertNil(converter.toEthDecimal)
		XCTAssertNil(converter.toEthDouble)
	}

}
