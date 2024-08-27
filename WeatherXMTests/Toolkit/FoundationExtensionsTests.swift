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

	func testDictionary() {
		var dict: [String: Int] = .init()
		dict += ["one": 1]
		let expectedDict = ["one": 1]
		XCTAssert(dict == expectedDict, "Dict should be \(expectedDict)")
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
		_ = array.remove { $0 < 2 }
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

// MARK: - Strings
extension FoundationExtensionsTests {
	func testWalletAddressMaskString() {
		let address = "0x69516D787ea2b1521832a90fD2Ef5BfcaBE11552"
		let expectedMaskedAddress = "0x6951****1552"
		XCTAssert(address.walletAddressMaskString == expectedMaskedAddress,
				  "The address should be \(expectedMaskedAddress)")
	}

	func testCapitalizedSentence() {
		let sentence = "this is a sentence"
		let expectedResult = "This is a sentence"
		XCTAssert(sentence.capitalizedSentence == expectedResult, "The capitalized sentence shoudl be \"\(expectedResult)\"")
	}

	func testSemVersionCompare() {
		let version = "3.2.0"
		let	patchRelease = "3.2.1"
		let minorRelease = "3.3.0"
		let majorRelease = "4.0.0"
		let invalidVersion = "4.0.b"

		XCTAssert(version.semVersionCompare(version) == .orderedSame, "Shoul be equal")
		XCTAssert(version.semVersionCompare(patchRelease) == .orderedAscending, "\(patchRelease) is greater than \(version)")
		XCTAssert(version.semVersionCompare(minorRelease) == .orderedAscending, "\(minorRelease) is greater than \(version)")
		XCTAssert(version.semVersionCompare(majorRelease) == .orderedAscending, "\(majorRelease) is greater than \(version)")
		XCTAssert(version.semVersionCompare(invalidVersion) == .orderedAscending, "\(invalidVersion) is greater than \(version)")
	}
}

// MARK: - URL
extension FoundationExtensionsTests {
	func testIsHttp() {
		let httpsUrl = URL(string: "https://weatherxm.com")
		let httpUrl = URL(string: "http://weatherxm.com")
		let nonHttpUrl = URL(string: "weatherxm.com")
		XCTAssertNotNil(httpUrl)
		XCTAssertNotNil(httpsUrl)
		XCTAssertNotNil(nonHttpUrl)

		XCTAssert(httpsUrl!.isHttp, "\(httpsUrl!) is http")
		XCTAssert(httpUrl!.isHttp, "\(httpUrl!) is http")
		XCTAssert(!nonHttpUrl!.isHttp, "\(nonHttpUrl!) is not http")
	}

	func testQueryParam() {
		let url = URL(string: "https://weatherxm.com?param=value")
		XCTAssertNotNil(url)

		let expectedResult = "value"
		XCTAssert(url!["param"] == expectedResult, "The param value should be \"\(expectedResult)\"")

		XCTAssertNil(url!["param1"], "The param1 value should be nil")
	}

	func testQueryItems() {
		let url = URL(string: "https://weatherxm.com?param=value")
		XCTAssertNotNil(url)
		let items = url?.queryItems
		XCTAssertNotNil(items)

		let expectedResult = "value"
		XCTAssert(items?["param"] == expectedResult, "The param value should be \"\(expectedResult)\"")
		XCTAssertNil(items?["param1"], "The param1 value should be nil")
	}

	func testAppendQueryItem() {
		var url = URL(string: "https://weatherxm.com")
		XCTAssertNotNil(url)
		url?.appendQueryItem(name: "param", value: "value")

		let items = url?.queryItems
		XCTAssertNotNil(items)

		let expectedResult = "value"
		XCTAssert(items?["param"] == expectedResult, "The param value should be \"\(expectedResult)\"")
		XCTAssertNil(items?["param1"], "The param1 value should be nil")
	}
}
