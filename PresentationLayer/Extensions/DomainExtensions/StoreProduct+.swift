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
                     trial: self.trialPeriodString?.title)
	}

    func toSubscriptionPlan(showPrice: Bool) -> SubscriptionPlanView.Plan {
        let offer = SubscriptionPlanView.Offer(offerText: launchOfferText,
                                               trialTitle: trialPeriodString?.title,
                                               trialDescription: trialPeriodString?.description)
        let price = promoLaunchDisplayPrice ?? displayPrice
        return .init(fontIcon: .sparkles,
                     title: LocalizableString.Subscriptions.premium.localized,
                     subtitle: subtitle,
                     offer: offer,
                     isCurrent: isSubscribed,
                     price: showPrice ? price : nil,
                     period: pricePeriodString,
                     description: LocalizableString.Subscriptions.premiumSuscriptionDescription.localized,
                     bullets: [LocalizableString.Subscriptions.premiumSubscriptionBulllet0.localized,
                               LocalizableString.Subscriptions.premiumSubscriptionBulllet1.localized,
                               LocalizableString.Subscriptions.premiumSubscriptionBulllet2.localized,
                               LocalizableString.Subscriptions.premiumSubscriptionBulllet3.localized],
                     productId: identifier,
                     isWarning: false,
                     isPremium: true)
    }

	var pricePeriodString: String {
		guard let perUnit = period?.perUnit else {
			return ""
		}

        return LocalizableString.Subscriptions.perFormat(perUnit).localized
	}

    var subtitle: String? {
        guard let promoLaunchPeriod else {
            return nil
        }
        
        return LocalizableString.Subscriptions.premiumSubtitle(promoLaunchPeriod.value,
                                                               promoLaunchPeriod.unitString?.localized ?? "",
                                                               displayPrice).localized
    }

    var launchOfferText: String? {
        guard let promoLaunchPeriod else {
            return nil
        }

        return LocalizableString.Subscriptions.limitedLaunchOffer.localized
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

    var trialPeriodString: (title: String, description: String)? {
		guard hasFreeTrial, let trialPeriod else {
			return nil
		}

        let title = LocalizableString.Subscriptions.freeTrialTitle(trialPeriod.value, trialPeriod.unitString?.localized ?? "").localized
        let description = LocalizableString.Subscriptions.freeTrialDescription(trialPeriod.value, trialPeriod.unitString?.localized ?? "", 200, "PROMO-CODE-HERE").localized

        return (title, description)
	}

    var trialPeriodBadgeString: String? {
        guard hasFreeTrial, let trialPeriod else {
            return nil
        }

        return LocalizableString.Subscriptions.freePeriod(trialPeriod.value, trialPeriod.unitString?.localized.lowercased() ?? "").localized
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

extension StoreProduct.PeriodUnit {
    var tabTitle: String {
        switch self {
            case .day:
                LocalizableString.daily.localized
            case .week:
                LocalizableString.week.localized
            case .month:
                LocalizableString.Subscriptions.monthly.localized
            case .year:
                LocalizableString.Subscriptions.annual.localized
        }
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
