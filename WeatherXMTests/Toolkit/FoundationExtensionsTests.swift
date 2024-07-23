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
		XCTAssert(index == 1, "Index should 1")

		XCTAssert(TestCases.one.index == 0, "Index should be 0")

		let value = TestCases.value(for: 2)
		XCTAssert(value == .three, "Value should three")
    }

	func testToFloat() {
		let integer = 4
		XCTAssert(integer.toFloat == 4.0, "Conversion to float failed")
	}
}

// MARK: - Array, Colection tests
extension FoundationExtensionsTests {
	
	func testWithNoDuplicates() {
		let array = [1, 4, 2, 0, 2, 1, 7]
		let expectedArray = [1, 4, 2, 0, 7]
		let arrayWithNoDuplicates = array.withNoDuplicates
		XCTAssert(arrayWithNoDuplicates == expectedArray, "The array should contain unique elements")
	}

	func testRemoveWhile() {
		var array = [1, 4, 2, 0, 2, 1, 7]
		let expectedArray = [4, 2, 0, 2, 1, 7]
		let _ = array.remove { $0 < 2 }
		XCTAssert(array == expectedArray, "The array should be \(expectedArray)")
	}

	func testSafeAccess() {
		let array = [1, 4, 2, 0, 2, 1, 7]
		
		let outOfBoundsElement = array[safe: 7]
		XCTAssertNil(outOfBoundsElement, "Out of bounds element should be nil")
		
		let negativeIndex = array[safe: -1]
		XCTAssertNil(outOfBoundsElement, "Negative index element should be nil")
		
		let valid = array[safe: 2]
		XCTAssertNotNil(valid, "Valid index should not be nil")
	}

	func testSortedByCriteria() {
		let array = ["one", "two", "three", "zero", "ten"]
		let expectedResult = ["one", "ten", "two", "zero", "three"]
		let sortedArray = array.sortedByCriteria(criterias: [ { $0.count < $1.count }, { $0 < $1 }])

		XCTAssert(sortedArray == expectedResult, "The sorted array should be \(expectedResult)")
	}
}
