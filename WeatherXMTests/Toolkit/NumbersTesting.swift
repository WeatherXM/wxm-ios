//
//  NumbersTesting.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 20/1/25.
//

import Testing
@testable import Toolkit

struct DoublesTesting {

    @Test func rounded() async throws {
        let number: Double = 3.14159
		#expect(number.rounded(toPlaces: 0) == 3)
		#expect(number.rounded(toPlaces: 1) == 3.1)
		#expect(number.rounded(toPlaces: 2) == 3.14)
		#expect(number.rounded(toPlaces: 3) == 3.142)
		#expect(number.rounded(toPlaces: 4) == 3.1416)
		#expect(number.rounded(toPlaces: -1) == 0)
		#expect(number.rounded(toPlaces: -2) == 0)

		let moreDigits: Double = 12.3456
		#expect(moreDigits.rounded(toPlaces: -1) == 10)
		#expect(moreDigits.rounded(toPlaces: -2) == 0)
    }

	@Test func intValueRounded() async throws {
		var number: Double = 3.14159
		#expect(number.intValueRounded == 3)
		number = 3.5
		#expect(number.intValueRounded == 4)
		number = 0.5
		#expect(number.intValueRounded == 1)
		number = 0.125
		#expect(number.intValueRounded == 0)
	}

	@Test func precision() async throws {
		let comma = Locale.current.decimalSeparator ?? ""
		var number: Double = 3.14159
		#expect(number.toWXMTokenPrecisionString == "3\(comma)14")
		number = 3.00
		#expect(number.toWXMTokenPrecisionString == "3\(comma)00")
		number = 3.10
		#expect(number.toPrecisionString(precision: 2) == "3\(comma)1")
		#expect(number.toPrecisionString(minDecimals: 2, precision: 2) == "3\(comma)10")
		number = 3.10
		#expect(number.toPrecisionString(precision: 0) == "3")
		#expect(number.toPrecisionString(precision: -1) == "3\(comma)1")
	}
}
