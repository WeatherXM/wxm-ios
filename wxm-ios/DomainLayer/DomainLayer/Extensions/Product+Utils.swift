//
//  Product+Utils.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 13/11/25.
//

import StoreKit

extension Product {
	func getRenewalDate(productId: String) async -> Date? {
		let statuses = try? await subscription?.status
		let status = statuses?.first { status in
			if case .verified(let transaction) = status.transaction {
				return transaction.productID == productId
			}
			return false
		}

		var renewalDate: Date?
		if case .verified(let renewalInfo) = status?.renewalInfo {
			renewalDate = renewalInfo.renewalDate
		}

		return renewalDate
	}

	func isCanceled(productId: String) async -> Bool {
		let statuses = try? await subscription?.status
		let status = statuses?.first { status in
			if case .verified(let transaction) = status.transaction {
				return transaction.productID == productId
			}
			return false
		}

		if case .subscribed = status?.state, case .verified(let renewalInfo) = status?.renewalInfo {
			return !renewalInfo.willAutoRenew
		}

		return false
	}

	func expirationDate(productId: String) async -> Date? {
		let statuses = try? await subscription?.status
		let status = statuses?.first { status in
			if case .verified(let transaction) = status.transaction {
				return transaction.productID == productId
			}
			return false
		}

		if case .subscribed = status?.state,
			case .verified(let renewalInfo) = status?.renewalInfo,
		   !renewalInfo.willAutoRenew,
		   case .verified(let transaction) = status?.transaction {
			return transaction.expirationDate
		}

		return nil
	}

	func introductoryOffer() -> SubscriptionOffer? {
		subscription?.introductoryOffer
	}

	func isUserEligibleForIntroductoryOffer() async -> Bool {
		guard let subscription, subscription.introductoryOffer != nil else {
			return false
		}

		return await subscription.isEligibleForIntroOffer
	}
}
