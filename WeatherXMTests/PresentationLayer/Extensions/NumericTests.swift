//
//  NumericTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 28/4/25.
//

import Testing
@testable import WeatherXM
import Foundation

struct NumericTests {

	@Test
	func initializeCGFloatWithDimension() throws {
		Dimension.allCases.forEach {
			#expect(CGFloat($0) == $0.value)
		}
	}

	@Test
	func initializeCGFloatWithFontSize() throws {
		FontSizeEnum.allCases.forEach {
			#expect(CGFloat($0) == $0.sizeValue)
		}
	}

	@Test
	 func convertDoubleToTemperatureUnit() throws {
		 let celsiusValue: Double = 25.0
		 #expect(celsiusValue.toTemeratureUnit(.celsius) == 25.0)
		 #expect(celsiusValue.toTemeratureUnit(.fahrenheit) == 77.0)
	 }

	 @Test
	 func convertDoubleToTemperatureString() throws {
		 let celsiusValue: Double = 25.0
		 #expect(celsiusValue.toTemeratureString(for: .celsius) == "25°C")
		 #expect(celsiusValue.toTemeratureString(for: .fahrenheit) == "77°F")
	 }

	@Test
	func localizedFormatted() throws {
		let comma = Locale.current.groupingSeparator ?? ""
		#expect(1000.localizedFormatted == "1\(comma)000")
		#expect(1234567.localizedFormatted == "1\(comma)234\(comma)567")
	}

	@Test
	func rewardScoreFontIcon() throws {
		#expect(10.rewardScoreFontIcon == .hexagonXmark)
		#expect(50.rewardScoreFontIcon == .hexagonExclamation)
		#expect(100.rewardScoreFontIcon == .hexagonCheck)
		#expect(120.rewardScoreFontIcon == .hexagonExclamation)
	}

	@Test
	func rewardScoreColor() throws {
		#expect(10.rewardScoreColor == .error)
		#expect(50.rewardScoreColor == .warning)
		#expect(100.rewardScoreColor == .success)
		#expect(120.rewardScoreColor == .noColor)
	}

	@Test
	func rewardScoreType() throws {
		#expect(10.rewardScoreType == .error)
		#expect(50.rewardScoreType == .warning)
		#expect(100.rewardScoreType == nil)
	}

	@Test
	func toCompactDecimalFormat() throws {
		let comma = Locale.current.decimalSeparator ?? ""
		let groupingComma = Locale.current.groupingSeparator ?? ""

		#expect(1000.toCompactDecimaFormat == "1K")
		#expect(1500.toCompactDecimaFormat == "1\(comma)5K")
		#expect(1_000_000.toCompactDecimaFormat == "1M")
		#expect(1_500_000.toCompactDecimaFormat == "1\(comma)5M")
		#expect(1_000_000_000.toCompactDecimaFormat == "1B")
		#expect((-1500).toCompactDecimaFormat == "-1\(groupingComma)500")
		#expect(999.toCompactDecimaFormat == "999")
	}
}
