//
//  Int+.swift
//  PresentationLayer
//
//  Created by Lampros Zouloumis on 22/8/22.
//

import Foundation
import Toolkit
// https://stackoverflow.com/questions/48371093/swift-4-formatting-numbers-into-friendly-ks
extension Int {
	func formatNumber() -> String {
		let num = abs(Double(self))
		let sign = (self < 0) ? "-" : ""

		switch num {
			case 1_000_000_000...:
				var formatted = num / 1_000_000_000
				formatted = formatted.reduceScale(to: 1)
				return "\(sign)\(formatted)B"

			case 1_000_000...:
				var formatted = num / 1_000_000
				formatted = formatted.reduceScale(to: 1)
				return "\(sign)\(formatted)M"

			case 1000...:
				var formatted = num / 1000
				formatted = formatted.reduceScale(to: 1)
				return "\(sign)\(formatted)K"

			case 0...:
				return "\(self)"

			default:
				return "\(sign)\(self)"
		}
	}

	var localizedFormatted: String {
		NumberFormatter.localizedString(from: NSNumber(value: self), number: .decimal)
	}

	var rewardScoreFontIcon: FontIcon {
		switch self {
			case _ where self < 20:
				return .hexagonXmark
			case _ where self < 80:
				return .hexagonExclamation
			case _ where self <= 100:
				return .hexagonCheck
			default:
				return .hexagonExclamation
		}
	}

	var rewardScoreColor: ColorEnum {
		switch self {
			case _ where self < 20:
				return .error
			case _ where self < 80:
				return .warning
			case _ where self <= 100:
				return .success
			default:
				return .noColor
		}
	}

	var rewardScoreType: CardWarningType? {
		switch self {
			case _ where self < 20:
				return .error
			case _ where self < 80:
				return .warning
			default:
				return nil
		}
	}
}
