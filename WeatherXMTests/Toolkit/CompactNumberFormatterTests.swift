//
//  CompactNumberFormatterTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 19/7/24.
//

import XCTest
@testable import Toolkit

final class CompactNumberFormatterTests: XCTestCase {
	let formatter = CompactNumberFormatter()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testIntegers() throws {
		let decimalSeparator = Locale.current.decimalSeparator ?? ""
		let expectedResults = [1: "1",
							   100: "100",
							   1000: "1K",
							   10000: "10K",
							   10010: "10K",
							   10110: "10\(decimalSeparator)1K",
							   10190: "10\(decimalSeparator)2K",
							   110110: "110\(decimalSeparator)1K",
							   1000110: "1M",
							   1200110: "1\(decimalSeparator)2M",
							   1990110: "2M",
							   11200110: "11\(decimalSeparator)2M",
							   111200110: "111\(decimalSeparator)2M",
							   1111200110: "1\(decimalSeparator)1B"]

		expectedResults.forEach { key, value in
			let str = formatter.string(for: key)
			XCTAssert(str == value, "The result is \(String(describing: str)), it should be \(value) for \(key)")
		}
    }

	func testFloats() throws {
		let decimalSeparator = Locale.current.decimalSeparator ?? ""
		let expectedResults = [1.0: "1",
							   1.2: "1",
							   1.9: "2",
							   100.0: "100",
							   1000.0: "1K",
							   10000.0: "10K",
							   10010.0: "10K",
							   10110.0: "10\(decimalSeparator)1K",
							   10190.0: "10\(decimalSeparator)2K",
							   110110.0: "110\(decimalSeparator)1K",
							   1000110.0: "1M",
							   1200110.0: "1\(decimalSeparator)2M",
							   1990110.0: "2M",
							   11200110.0: "11\(decimalSeparator)2M",
							   111200110.0: "111\(decimalSeparator)2M",
							   1111200110.0: "1\(decimalSeparator)1B"]

		expectedResults.forEach { key, value in
			let str = formatter.string(for: key)
			XCTAssert(str == value, "The result is \(String(describing: str)), it should be \(value) for \(key)")
		}
	}

	func testNSNumbers() throws {
		let decimalSeparator = Locale.current.decimalSeparator ?? ""
		let expectedResults = [NSNumber(1.0): "1",
							   NSNumber(1.2): "1",
							   NSNumber(1.9): "2",
							   NSNumber(100.0): "100",
							   NSNumber(1000.0): "1K",
							   NSNumber(10000.0): "10K",
							   NSNumber(10010.0): "10K",
							   NSNumber(10110.0): "10\(decimalSeparator)1K",
							   NSNumber(10190.0): "10\(decimalSeparator)2K",
							   NSNumber(110110.0): "110\(decimalSeparator)1K",
							   NSNumber(1000110.0): "1M",
							   NSNumber(1200110.0): "1\(decimalSeparator)2M",
							   NSNumber(1990110.0): "2M",
							   NSNumber(11200110.0): "11\(decimalSeparator)2M",
							   NSNumber(111200110.0): "111\(decimalSeparator)2M",
							   NSNumber(1111200110.0): "1\(decimalSeparator)1B"]

		expectedResults.forEach { key, value in
			let str = formatter.string(for: key)
			XCTAssert(str == value, "The result is \(String(describing: str)), it should be \(value) for \(key)")
		}
	}

}
