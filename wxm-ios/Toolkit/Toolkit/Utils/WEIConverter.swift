//
//  WEIConverter.swift
//  Toolkit
//
//  Created by Pantelis Giazitsis on 1/12/23.
//

import Foundation

public struct WEIConverter {
	private let weiString: String
	private let etherInWei = pow(Decimal(10), 18)

	init(value: String) {
		self.weiString = value
	}

	var toEthDouble: Double? {
		guard let decimal = toEthDecimal else {
			return nil
		}
		
		return NSDecimalNumber(decimal: decimal).doubleValue
	}
}

extension WEIConverter {
	var toEthDecimal: Decimal? {
		guard var decimal = Decimal(string: weiString) else {
			return nil
		}

		var etherInWei = self.etherInWei
		var result: Decimal = .nan
		NSDecimalMultiplyByPowerOf10(&result, &decimal, -18, .up)
		return result
	}
}

public extension String {
	var toEthDouble: Double? {
		let converter = WEIConverter(value: self)
		return converter.toEthDouble
	}
}
