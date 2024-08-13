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
		let expectedResults = [1: "1",
							   100: "100",
							   1000: "1K",
							   10000: "10K",
							   10010: "10K",
							   10110: "10,1K",
							   10190: "10,2K",
							   110110: "110,1K",
							   1000110: "1M",
							   1200110: "1,2M",
							   1990110: "2M",
							   11200110: "11,2M",
							   111200110: "111,2M",
							   1111200110: "1,1B"]

		expectedResults.forEach { key, value in
			let str = formatter.string(for: key)
			XCTAssert(str == value, "The result is \(String(describing: str)), it should be \(value) for \(key)")
		}
    }

	func testFloats() throws {
		let expectedResults = [1.0: "1",
							   1.2: "1",
							   1.9: "2",
							   100.0: "100",
							   1000.0: "1K",
							   10000.0: "10K",
							   10010.0: "10K",
							   10110.0: "10,1K",
							   10190.0: "10,2K",
							   110110.0: "110,1K",
							   1000110.0: "1M",
							   1200110.0: "1,2M",
							   1990110.0: "2M",
							   11200110.0: "11,2M",
							   111200110.0: "111,2M",
							   1111200110.0: "1,1B"]

		expectedResults.forEach { key, value in
			let str = formatter.string(for: key)
			XCTAssert(str == value, "The result is \(String(describing: str)), it should be \(value) for \(key)")
		}
	}

	func testNSNumbers() throws {
		let expectedResults = [NSNumber(floatLiteral: 1.0): "1",
							   NSNumber(floatLiteral: 1.2): "1",
							   NSNumber(floatLiteral: 1.9): "2",
							   NSNumber(floatLiteral: 100.0): "100",
							   NSNumber(floatLiteral: 1000.0): "1K",
							   NSNumber(floatLiteral: 10000.0): "10K",
							   NSNumber(floatLiteral: 10010.0): "10K",
							   NSNumber(floatLiteral: 10110.0): "10,1K",
							   NSNumber(floatLiteral: 10190.0): "10,2K",
							   NSNumber(floatLiteral: 110110.0): "110,1K",
							   NSNumber(floatLiteral: 1000110.0): "1M",
							   NSNumber(floatLiteral: 1200110.0): "1,2M",
							   NSNumber(floatLiteral: 1990110.0): "2M",
							   NSNumber(floatLiteral: 11200110.0): "11,2M",
							   NSNumber(floatLiteral: 111200110.0): "111,2M",
							   NSNumber(floatLiteral: 1111200110.0): "1,1B"]

		expectedResults.forEach { key, value in
			let str = formatter.string(for: key)
			XCTAssert(str == value, "The result is \(String(describing: str)), it should be \(value) for \(key)")
		}
	}

}
