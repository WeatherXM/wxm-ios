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
	func InitializeCGFloatWithDimension() throws {
		Dimension.allCases.forEach {
			#expect(CGFloat($0) == $0.value)
		}
	}

	@Test
	func InitializeCGFloatWithFontSize() throws {
		FontSizeEnum.allCases.forEach {
			#expect(CGFloat($0) == $0.sizeValue)
		}
	}
}
