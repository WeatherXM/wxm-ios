//
//  StoreProduct+.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 11/11/25.
//

import DomainLayer
import Toolkit

extension StoreProduct {
	var toSubcriptionViewCard: SubscriptionCardView.Card {
		.init(title: self.name.uppercased(),
			  price: self.displayPrice,
			  description: self.description)
	}

	var pricePeriodString: String {
		guard let perUnit = period?.perUnit else {
			return ""
		}

		return "\(displayPrice)/\(perUnit)"
	}

	var nextBillingDateString: String? {
		guard let renewalDate else {
			return nil
		}

		return LocalizableString.Subscriptions.nextBillingDate(renewalDate.getFormattedDate(format: .monthLiteralDayYear).capitalized).localized
	}
}

extension StoreProduct.Period {
	var perUnit: String? {
		guard let unit else {
			return nil
		}

		var unitString: LocalizableString?
		let isPlural = value > 1
		switch unit {
			case .day:
				unitString = isPlural ? .days : .day
			case .week:
				unitString = isPlural ? .weeks : .week
			case .month:
				unitString = isPlural ? .months : .month
			case .year:
				unitString = isPlural ? .years : .year
		}

		let valueString = value > 1 ? "\(value) " : ""
		return "\(valueString)\(unitString?.localized.lowercased() ?? "")"
	}
}
