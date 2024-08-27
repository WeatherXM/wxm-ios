//
//  LocalizableString+Errors.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 6/9/23.
//

import Foundation

extension LocalizableString {
    enum Error {
        case genericMessage
        case networkGeneric
        case networkTimedOut
        case historyNoDataOnDay
        case loginInvalidCredentials
        case signupUserAlreadyExists1
        case signupUserAlreadyExists2
        case userDeviceNotFound
        case deepLinkInvalidUrl
        case noInternetAccess
		case unsupportedApplicationVersion
		case obcTitle
		case obcDescription(String)
		case spikesTitle
		case unidentifiedSpikeTitle
		case unownedSpikesDescription(String)
		case unidentifiedSpikeDescription(String)
		case unownedUnidentifiedSpikeDescription(String)
		case spikesDescription(String)
		case noMedianTitle
		case unownedNoMedianDescription
		case noMedianDescription
		case noDataTitle
		case unownedNoDataDescription
		case noDataDescription
		case shortConstTitle
		case unownedShortConstDescription(String)
		case shortConstDescription(String)
		case longConstTitle
		case unownedLongConstDescription(String)
		case longConstDescription(String)
		case frozenSensorTitle
		case frozenSensorDescription
		case anomIncreaseTitle
		case unidentifiedAnomalousChangeTitle
		case unownedAnomIncreaseDescription(String)
		case anomIncreaseDescription(String)
		case unidentifiedAnomalousChangeDescription(String)
		case unownedUnidentifiedAnomalousDescription(String)
		case locationNotVerifiedTitle
		case locationNotVerifiedDescription
		case noLocationDataTitle
		case unownedNoLocationDataDescription
		case noLocationDataM5Description
		case noLocationDataHeliumDescription
		case noWalletTitle
		case unownedNoWalletDescription
		case noWalletDescription
		case relocatedTitle
		case relocatedDescription
		case cellCapacityReachedTitle
		case unownedCellCapacityReachedDescription
		case cellCapacityReachedDescription
		case polThresholdNotReachedTitle
		case qodThresholdNotReachedTitle
		case unownedPolThresholdNotReachedDescription
		case polThresholdNotReachedDescription
		case unownedQodThresholdNotReachedDescription
		case qodThresholdNotReachedDescription
		case unknownTitle
		case unownedUnknownDescription
		case unknownDescription
    }
}

extension LocalizableString.Error: WXMLocalizable {
	var localized: String {
		var localized = NSLocalizedString(key, comment: "")
		switch self {
			case .obcDescription(let text),
					.unownedSpikesDescription(let text),
					.spikesDescription(let text),
					.unownedShortConstDescription(let text),
					.shortConstDescription(let text),
					.unownedLongConstDescription(let text),
					.longConstDescription(let text),
					.unownedAnomIncreaseDescription(let text),
					.anomIncreaseDescription(let text),
					.unidentifiedSpikeDescription(let text),
					.unownedUnidentifiedSpikeDescription(let text),
					.unidentifiedAnomalousChangeDescription(let text),
					.unownedUnidentifiedAnomalousDescription(let text):
				localized = String(format: localized, text)
			default:
				break
		}
		return localized
    }

	var key: String {
		switch self {
			case .genericMessage:
				return "error_generic_message"
			case .networkGeneric:
				return "error_network_generic"
			case .networkTimedOut:
				return "error_network_timed_out"
			case .historyNoDataOnDay:
				return "error_history_no_data_on_day"
			case .loginInvalidCredentials:
				return "error_login_invalid_credentials"
			case .signupUserAlreadyExists1:
				return "error_signup_user_already_exists1"
			case .signupUserAlreadyExists2:
				return "error_signup_user_already_exists2"
			case .userDeviceNotFound:
				return "error_user_device_not_found"
			case .deepLinkInvalidUrl:
				return "error_deep_link_invalid_url"
			case .noInternetAccess:
				return "error_no_internet_access"
			case .unsupportedApplicationVersion:
				return "error_unsupported_application_version"
			case .obcTitle:
				return "error_obc_title"
			case .obcDescription:
				return "error_obc_description"
			case .spikesTitle:
				return "error_spikes_title"
			case .unidentifiedSpikeTitle:
				return "error_unidentified_spike_title"
			case .unownedSpikesDescription:
				return "error_unowned_spikes_description"
			case .spikesDescription:
				return "error_spikes_description"
			case .unidentifiedSpikeDescription:
				return "error_unidentified_spike_description"
			case .unownedUnidentifiedSpikeDescription:
				return "error_unowned_unidentified_spike_description"
			case .noMedianTitle:
				return "error_no_median_title"
			case .unownedNoMedianDescription:
				return "error_unowned_no_median_description"
			case .noMedianDescription:
				return "error_no_median_description"
			case .noDataTitle:
				return "error_no_data_title"
			case .unownedNoDataDescription:
				return "error_unowned_no_data_description"
			case .noDataDescription:
				return "error_no_data_description"
			case .shortConstTitle:
				return "error_short_const_title"
			case .unownedShortConstDescription:
				return "error_unowned_short_const_description"
			case .shortConstDescription:
				return "error_short_const_description"
			case .longConstTitle:
				return "error_long_const_title"
			case .unownedLongConstDescription:
				return "error_unowned_long_const_description"
			case .longConstDescription:
				return "error_long_const_description"
			case .frozenSensorTitle:
				return "error_frozen_sensor_title"
			case .frozenSensorDescription:
				return "error_frozen_sensor_description"
			case .anomIncreaseTitle:
				return "error_anom_increase_title"
			case .unidentifiedAnomalousChangeTitle:
				return "error_unidentified_anomalous_change_title"
			case .unownedAnomIncreaseDescription:
				return "error_unowned_anom_increase_description"
			case .anomIncreaseDescription:
				return "error_anom_increase_description"
			case .unidentifiedAnomalousChangeDescription:
				return "error_unidentified_anomalous_change_description"
			case .unownedUnidentifiedAnomalousDescription:
				return "error_unowned_unidentified_anomalous_change_description"
			case .locationNotVerifiedTitle:
				return "error_location_not_verified_title"
			case .locationNotVerifiedDescription:
				return "error_location_not_verified_description"
			case .noLocationDataTitle:
				return "error_no_location_data_title"
			case .unownedNoLocationDataDescription:
				return "error_unowned_no_location_data_description"
			case .noLocationDataM5Description:
				return "error_no_location_data_m5_description"
			case .noLocationDataHeliumDescription:
				return "error_no_location_data_helium_description"
			case .noWalletTitle:
				return "error_no_wallet_title"
			case .unownedNoWalletDescription:
				return "error_unowned_no_wallet_description"
			case .noWalletDescription:
				return "error_no_wallet_description"
			case .cellCapacityReachedTitle:
				return "error_cell_capacity_reached_title"
			case .unownedCellCapacityReachedDescription:
				return "error_unowned_cell_capacity_reached_description"
			case .cellCapacityReachedDescription:
				return "error_cell_capacity_reached_description"
			case .relocatedTitle:
				return "error_relocated_title"
			case .relocatedDescription:
				return "error_relocated_description"
			case .qodThresholdNotReachedTitle:
				return "error_qod_threshold_not_reached_title"
			case .unownedPolThresholdNotReachedDescription:
				return "error_unowned_pol_threshold_not_reached_description"
			case .polThresholdNotReachedTitle:
				return "error_pol_threshold_not_reached_title"
			case .unownedQodThresholdNotReachedDescription:
				return "error_unowned_qod_threshold_not_reached_description"
			case .qodThresholdNotReachedDescription:
				return "error_qod_threshold_not_reached_description"
			case .polThresholdNotReachedDescription:
				return "error_pol_threshold_not_reached_description"
			case .unknownTitle:
				return "error_unknown_title"
			case .unownedUnknownDescription:
				return "error_unowned_unknown_description"
			case .unknownDescription:
				return "error_unknown_description"
		}
	}
}
