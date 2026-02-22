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
        case free
        case freeSubtitle
        case bestAccuracy
		case premiumFeatures
		case premiumForecast
		case hyperLocalForecast
		case hyperLocalForecastDescription
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
		case premiumAvailableUntil
		case freeTrialTitle(Int, String)
        case freeTrialDescription(Int, String, Int)
        case freePeriod(Int, String)
		case perUnitPrice(String, String)
		case afterTrialCharge(String)
		case noProductError(String)
		case purchaseCancelledError
		case purchaseIsPendingError
		case purchaseFailedError
		case poweredByWeatherXM
		case poweredBy
        case loginToGetPremiumAlert
        case upgradeToPremium
        case getMostAccurateForecasts
        case monthly
        case annual
        case freeSubscriptionBullet0
        case freeSubscriptionBullet1
        case freeSubscriptionBullet2
        case freeSubscriptionBullet3
        case premiumSuscriptionDescription
        case premiumSubscriptionBulllet0
        case premiumSubscriptionBulllet1
        case premiumSubscriptionBulllet2
        case premiumSubscriptionBulllet3
        case cancelAnytimeDescription
        case downgradeToFreeplan
        case downgradeToFreeAlertTitle
        case downgradeToFreeAlertMessage
        case downgrade
        case stayOnPremium
        case youAreOnPremium
        case perFormat(String)
	}
}

extension LocalizableString.Subscriptions: WXMLocalizable {
	var localized: String {
		var localized = NSLocalizedString(key, comment: "")
		switch self {
			case .purchaseFailedDescription(let text),
				 .nextBillingDate(let text),
				 .afterTrialCharge(let text),
				 .noProductError(let text),
                 .perFormat(let text):
				localized = String(format: localized, text)
			case .freeTrialTitle(let count, let text),
                 .freePeriod(let count, let text):
				localized = String(format: localized, count, text)
			case .perUnitPrice(let text0, let text1):
				localized = String(format: localized, text0, text1)
            case .freeTrialDescription(let count, let text, let tokens):
                localized = String(format: localized, count, text, tokens)
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
			case .premiumForecast:
				"subscriptions_premium_forecast"
			case .hyperLocalForecast:
				"subscriptions_hyper_local_forecast"
			case .hyperLocalForecastDescription:
				"subscriptions_hyper_local_forecast_description"
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
			case .premiumAvailableUntil:
				"subscriptions_premium_available_until"
			case .freeTrialTitle:
				"subscriptions_free_trial"
            case .freeTrialDescription:
                "subscriptions_free_trial_description"
            case .freePeriod:
                "subscriptions_free_period"
            case .free:
                "subscriptions_free"
            case .freeSubtitle:
                "subscriptions_free_subtitle"
            case .bestAccuracy:
                "subscriptions_best_accuracy"
			case .perUnitPrice:
				"subscriptions_per_unit_price"
			case .afterTrialCharge:
				"subscriptions_after_trial_charge"
			case .noProductError:
				"subsriptions_no_product_error"
			case .purchaseCancelledError:
				"subscriptions_purchase_cancelled_error"
			case .purchaseIsPendingError:
				"subscriptions_purchase_is_pending_error"
			case .purchaseFailedError:
				"subscriptions_purchase_failed_error"
			case .poweredByWeatherXM:
				"subscriptions_powered_by_weatherxm"
			case .poweredBy:
				"subscriptions_powered_by"
            case .loginToGetPremiumAlert:
                "subscriptions_login_to_get_premium_alert"
            case .upgradeToPremium:
                "subscriptions_upgrade_to_premium"
            case .getMostAccurateForecasts:
                "subscriptions_get_most_accurate_forecasts"
            case .monthly:
                "subscriptions_monthly"
            case .annual:
                "subscriptions_annual"
            case .freeSubscriptionBullet0:
                "subscriptions_free_subscription_bullet_0"
            case .freeSubscriptionBullet1:
                "subscriptions_free_subscription_bullet_1"
            case .freeSubscriptionBullet2:
                "subscriptions_free_subscription_bullet_2"
            case .freeSubscriptionBullet3:
                "subscriptions_free_subscription_bullet_3"
            case .premiumSuscriptionDescription:
                "subscriptions_premium_suscription_description"
            case .premiumSubscriptionBulllet0:
                "subscriptions_premium_subscription_bulllet_0"
            case .premiumSubscriptionBulllet1:
                "subscriptions_premium_subscription_bulllet_1"
            case .premiumSubscriptionBulllet2:
                "subscriptions_premium_subscription_bulllet_2"
            case .premiumSubscriptionBulllet3:
                "subscriptions_premium_subscription_bulllet_3"
            case .cancelAnytimeDescription:
                "subscriptions_cancel_anytime_description"
            case .downgradeToFreeplan:
                "subscriptions_downgrade_to_freeplan"
            case .downgradeToFreeAlertTitle:
                "subscriptions_downgrade_to_free_alert_title"
            case .downgradeToFreeAlertMessage:
                "subscriptions_downgrade_to_free_alert_message"
            case .downgrade:
                "subscriptions_downgrade"
            case .stayOnPremium:
                "subscriptions_stay_on_premium"
            case .youAreOnPremium:
                "subscriptions_you_are_on_premium"
            case .perFormat:
                "subscriptions_per_format"
        }
	}
}
