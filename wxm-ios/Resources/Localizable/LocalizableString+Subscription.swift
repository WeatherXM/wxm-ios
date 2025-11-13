//
//  LocalizableString+Subscription.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 10/11/25.
//

import Foundation

extension LocalizableString {
	enum Subscriptions {
		case manageSubscription
		case currentPlan
		case standard
		case canceled
		case standardDescription
		case premium
		case active
		case premiumFeatures
		case mosaicForecast
		case mosaicForecastDescription
		case hourlyForecast
		case hourlyForecastDescription
		case getPremium
		case selectPlan
		case premiumSubscriptionUlocked
		case premiumFeaturesUnlocked
		case purchaseFailed
		case purchaseFailedDescription(String)
		case cancelSubscription
		case nextBillingDate(String)
	}
}

extension LocalizableString.Subscriptions: WXMLocalizable {
	var localized: String {
		var localized = NSLocalizedString(key, comment: "")
		switch self {
			case .purchaseFailedDescription(let text),
					.nextBillingDate(let text):
				localized = String(format: localized, text)
			default: break
		}

		return localized
	}

	var key: String {
		switch self {
			case .manageSubscription:
				"subscriptions_manage_subscription"
			case .currentPlan:
				"subscriptions_current_plan"
			case .standard:
				"subscriptions_standard"
			case .canceled:
				"subscriptions_canceled"
			case .standardDescription:
				"subscriptions_standard_description"
			case .premium:
				"subscriptions_premium"
			case .active:
				"subscriptions_active"
			case .premiumFeatures:
				"subscriptions_premium_features"
			case .mosaicForecast:
				"subscriptions_mosaic_forecast"
			case .mosaicForecastDescription:
				"subscriptions_mosaic_forecast_description"
			case .hourlyForecast:
				"subscriptions_hourly_forecast"
			case .hourlyForecastDescription:
				"subscriptions_hourly_forecast_description"
			case .getPremium:
				"subscriptions_get_premium"
			case .selectPlan:
				"subscriptions_select_plan"
			case .premiumSubscriptionUlocked:
				"subscriptions_premium_subscription_unlocked"
			case .premiumFeaturesUnlocked:
				"subscriptions_premium_features_unlocked"
			case .purchaseFailed:
				"subscriptions_purchase_failed"
			case .purchaseFailedDescription:
				"subscriptions_purchase_failed_description"
			case .cancelSubscription:
				"subscriptions_cancel_subscription"
			case .nextBillingDate:
				"subscriptions_next_billing_date"
		}
	}
}
