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
	public let period: Period?

	init(product: Product, isSubscribed: Bool) {
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
	}
}

public extension StoreProduct {
	struct Period {
		public let value: Int
		public let unit: PeriodUnit?
	}

	enum PeriodUnit {
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
