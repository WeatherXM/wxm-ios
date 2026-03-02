//
//  StoreProduct.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 11/11/25.
//

import Foundation
import StoreKit

public struct StoreProduct {
	public let identifier: String
	public let name: String
	public let description: String
	public let displayPrice: String
	public let isSubscribed: Bool
	public let renewalDate: Date?
	public let period: Period?
	public let isCanceled: Bool
	public let expirationDate: Date?
	public let hasFreeTrial: Bool
	public let trialPeriod: Period?
    public let promoLaunchDisplayPrice: String?
    public let promoLaunchPeriod: Period?

	init(product: Product,
		 isSubscribed: Bool,
		 renewalDate: Date?,
		 isCanceled: Bool,
		 expirationDate: Date?,
		 hasFreeTrial: Bool) {
		self.identifier = product.id
		self.name = product.displayName
		self.description = product.description
		self.displayPrice = product.displayPrice
		self.isSubscribed = isSubscribed
		if let subscription = product.subscription {
			self.period = .init(value: subscription.subscriptionPeriod.value, unit: PeriodUnit(unit: subscription.subscriptionPeriod.unit))
		} else {
			self.period = nil
		}

		self.renewalDate = renewalDate
		self.isCanceled = isCanceled
		self.expirationDate = expirationDate
		self.hasFreeTrial = hasFreeTrial

        if hasFreeTrial {
            self.trialPeriod = .init(value: 2, unit: .month)
        } else {
            self.trialPeriod = nil
        }

		if let introductoryOffer = product.subscription?.introductoryOffer {
            let introductoryOfferPeriod = introductoryOffer.period
			self.promoLaunchPeriod = .init(value: introductoryOffer.periodCount, unit: PeriodUnit(unit: introductoryOfferPeriod.unit))
		} else {
			self.promoLaunchPeriod = nil
		}

        self.promoLaunchDisplayPrice = product.subscription?.introductoryOffer?.displayPrice
	}
}

public extension StoreProduct {
	struct Period {
		public let value: Int
		public let unit: PeriodUnit?
	}

	enum PeriodUnit: Comparable {
		case day
		case week
		case month
		case year

		init?(unit: Product.SubscriptionPeriod.Unit) {
			switch unit {
				case .day:
					self = .day
				case .week:
					self = .week
				case .month:
					self = .month
				case .year:
					self = .year
				@unknown default:
					return nil
			}
		}
	}
}
