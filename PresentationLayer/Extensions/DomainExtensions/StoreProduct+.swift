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
		let hasTrial = self.trialPeriod != nil
		let desc = hasTrial ? LocalizableString.Subscriptions.afterTrialCharge(pricePeriodLiteralString).localized : self.description
		return .init(title: self.name.uppercased(),
					 price: self.pricePeriodString,
					 description: desc,
					 trial: self.trialPeriodString)
	}

	var pricePeriodString: String {
		guard let perUnit = period?.perUnit else {
			return ""
		}

		return "\(displayPrice)/\(perUnit)"
	}

	var pricePeriodLiteralString: String {
		guard let perUnit = period?.perUnit else {
			return ""
		}

		return LocalizableString.Subscriptions.perUnitPrice(displayPrice, perUnit).localized
	}

	var nextBillingDateString: String? {
		guard let renewalDate else {
			return nil
		}

		return LocalizableString.Subscriptions.nextBillingDate(renewalDate.getFormattedDate(format: .monthLiteralDayYear).capitalized).localized
	}

	var expirationDateString: String? {
		return LocalizableString.Subscriptions.premiumAvailableUntil.localized
	}

	var trialPeriodString: String? {
		guard hasFreeTrial, let trialPeriod else {
			return nil
		}
		
		return LocalizableString.Subscriptions.freeTrial(trialPeriod.value, trialPeriod.unitString?.localized ?? "").localized
	}
}

extension StoreProduct.Period {
	var perUnit: String? {
		guard let unitString else {
			return nil
		}

		let valueString = value > 1 ? "\(value) " : ""
		return "\(valueString)\(unitString.localized.lowercased())"
	}

	var unitString: LocalizableString? {
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

		return unitString
	}
}

extension StoreProductError {
	var localiizedDescription: String {
		switch self {
			case .noProductWithID(let productId):
				LocalizableString.Subscriptions.noProductError(productId).localized
			case .purchaseCancelled:
				LocalizableString.Subscriptions.purchaseCancelledError.localized
			case .purchaseIsPending:
				LocalizableString.Subscriptions.purchaseIsPendingError.localized
			case .purchaseFailed:
				LocalizableString.Subscriptions.purchaseFailedError.localized
		}
	}

}
