//
//  FoundationExtensionsTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 22/7/24.
//

import XCTest
@testable import Toolkit

final class FoundationExtensionsTests: XCTestCase {

    func testCaseIterable() throws {
		enum TestCases: CaseIterable {
			case one
			case two
			case three
		}

		let index = TestCases.index(for: .two)
		XCTAssert(index == 1)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
