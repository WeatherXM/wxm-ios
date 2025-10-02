//
//  LocalizableString+DeviceInfo.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 9/10/24.
//

import Foundation

extension LocalizableString {
	enum DeviceInfo {
		case title
		case stationName
		case stationLocation
		case ownedStationLocationDescription(String)
		case stationLocationDescription(String)
		case stationLocationButtonTitle
		case stationFrequency
		case stationReboot
		case stationMaintenance(String)
		case stationRemove
		case stationReconfigureWifi
		case stationHeliumFrequencyDescription(String)
		case stationRebootDescription
		case stationMaintenanceDescription(String)
		case stationRemoveDescription(String)
		case stationReconfigureWifiDescription
		case stationRemoveWarning
		case buttonChangeName
		case buttonChangeFrequency
		case buttonReboot
		case buttonEnterMaintenance
		case buttonRemove
		case buttonReconfigureWifi
		case stationInformation
		case stationInfoName
		case stationInfoModel
		case stationInfoBundleName
		case stationInfoDevEUI
		case stationInfoHardwareVersion
		case stationInfoFirmwareVersion
		case stationInfoLastHotspot
		case stationInfoLastRSSI
		case stationInfoSerialNumber
		case stationInfoATECC
		case stationInfoGPS
		case stationInfoWifiSignal
		case stationInfoBattery
		case editNameAlertTitle
		case editNameAlertMessage
		case invalidFriendlyName
		case claimDate
		case lastGatewayActivity
		case lastStationActivity
		case satellites(String)
		case followedContactSupportTitle
		case stationRebooted
		case stationRebootedDescription
		case stationBackToSettings
		case stationRebootFailed
		case stationRebootErrorDescription(String)
		case stationFrequencyChanged
		case stationFrequencyChangedDescription(String)
		case stationFrequencyChangeFailed
		case stationFrequencyChangeFailureDescription(String)
		case lowBatteryWarningMarkdown
		case gatewayLowBatteryWarningMarkdown
		case removeStationAccountConfirmationMarkdown
		case gatewayDetails
		case stationDetails
		case stationRssi
		case stationRssiWarning
		case stationRssiError
		case photoVerificationEmptyText
		case photoVerificationStartButtonTitle
		case photoVerificationUploadingDescription
		case photoVerificationWithPhotosDescription
		case gsmSignal
		case gwFrequency
		case externalSim
		case iccid
		case mobileCountryCode
		case gwBatteryState
		case signalGwStation
		case nextServerCommunication
		case stationId
		case signalStationGw
		case mobileCountryNetworkCode(String, String)
		case isInUse
	}
}

extension LocalizableString.DeviceInfo: WXMLocalizable {
	var localized: String {
		var localized = NSLocalizedString(self.key, comment: "")
		switch self {
			case .stationMaintenance(let text),
					.stationLocationDescription(let text),
					.ownedStationLocationDescription(let text),
					.stationHeliumFrequencyDescription(let text),
					.stationMaintenanceDescription(let text),
					.stationRemoveDescription(let text),
					.stationRebootErrorDescription(let text),
					.stationFrequencyChangedDescription(let text),
					.stationFrequencyChangeFailureDescription(let text),
					.satellites(let text):
				localized = String(format: localized, text)
			case .mobileCountryNetworkCode(let text0, let text1):
				localized = String(format: localized, text0, text1)
			default: break
		}

		return localized
	}

	var key: String {
		switch self {
			case .title:
				return "device_info_title"
			case .stationName:
				return "device_info_station_name"
			case .stationLocation:
				return "device_info_station_location"
			case .ownedStationLocationDescription:
				return "device_info_owned_station_location_description_format"
			case .stationLocationDescription:
				return "device_info_station_location_description_format"
			case .stationLocationButtonTitle:
				return "device_info_station_location_button_title"
			case .stationFrequency:
				return "device_info_station_frequency"
			case .stationReboot:
				return "device_info_station_reboot"
			case .stationMaintenance:
				return "device_info_station_maintenance_format"
			case .stationRemove:
				return "device_info_station_remove"
			case .stationReconfigureWifi:
				return "device_info_station_reconfigure_wifi"
			case .stationHeliumFrequencyDescription:
				return "device_info_station_helium_frequency_description_format"
			case .stationRebootDescription:
				return "device_info_station_reboot_description"
			case .stationMaintenanceDescription:
				return "device_info_station_maintenance_description_format"
			case .stationRemoveDescription:
				return "device_info_station_remove_description_format"
			case .stationReconfigureWifiDescription:
				return "device_info_station_reconfigure_wifi_description"
			case .stationRemoveWarning:
				return "device_info_station_remove_warning"
			case .buttonChangeName:
				return "device_info_button_change_name"
			case .buttonChangeFrequency:
				return "device_info_button_change_frequency"
			case .buttonReboot:
				return "device_info_button_reboot"
			case .buttonEnterMaintenance:
				return "device_info_button_enter_maintenance"
			case .buttonRemove:
				return "device_info_button_remove"
			case .buttonReconfigureWifi:
				return "device_info_button_reconfigure_wifi"
			case .stationInformation:
				return "device_info_station_information"
			case .stationInfoName:
				return "device_info_station_info_name"
			case .stationInfoModel:
				return "device_info_station_info_model"
			case .stationInfoBundleName:
				return "device_info_station_info_bundle_name"
			case .stationInfoDevEUI:
				return "device_info_station_info_dev_EUI"
			case .stationInfoHardwareVersion:
				return "device_info_station_info_hardware_version"
			case .stationInfoFirmwareVersion:
				return "device_info_station_info_firmware_version"
			case .stationInfoLastHotspot:
				return "device_info_station_info_last_hotspot"
			case .stationInfoLastRSSI:
				return "device_info_station_info_last_RSSI"
			case .stationInfoSerialNumber:
				return "device_info_station_info_serial_number"
			case .stationInfoATECC:
				return "device_info_station_info_ATECC"
			case .stationInfoGPS:
				return "device_info_station_info_GPS"
			case .stationInfoWifiSignal:
				return "device_info_station_info_wifi_signal"
			case .stationInfoBattery:
				return "device_info_station_info_battery"
			case .editNameAlertTitle:
				return "device_info_edit_name_alert_title"
			case .editNameAlertMessage:
				return "device_info_edit_name_alert_message"
			case .invalidFriendlyName:
				return "device_info_invalid_friendly_name"
			case .claimDate:
				return "device_info_claim_date"
			case .lastGatewayActivity:
				return "device_info_last_gateway_activity"
			case .lastStationActivity:
				return "device_info_last_station_activity"
			case .satellites:
				return "device_info_satellites"
			case .followedContactSupportTitle:
				return "device_info_followed_contact_support_title"
			case .stationRebooted:
				return "device_info_station_rebooted"
			case .stationRebootedDescription:
				return "device_info_station_rebooted_description"
			case .stationBackToSettings:
				return "device_info_station_back_to_settings"
			case .stationRebootFailed:
				return "device_info_station_reboot_failed"
			case .stationRebootErrorDescription:
				return "device_info_station_reboot_error_description_format"
			case .stationFrequencyChanged:
				return "device_info_station_frequency_changed"
			case .stationFrequencyChangedDescription:
				return "device_info_station_frequency_changed_description_format"
			case .stationFrequencyChangeFailed:
				return "device_info_station_frequency_change_failed"
			case .stationFrequencyChangeFailureDescription:
				return "device_info_station_frequency_change_failure_description_format"
			case .lowBatteryWarningMarkdown:
				return "device_info_low_battery_warning_markdown"
			case .gatewayLowBatteryWarningMarkdown:
				return "device_info_gateway_low_battery_warning_markdown"
			case .removeStationAccountConfirmationMarkdown:
				return "device_info_remove_station_account_confirmation_markdown"
			case .gatewayDetails:
				return "device_info_gateway_details"
			case .stationDetails:
				return "device_info_station_details"
			case .stationRssi:
				return "device_info_station_rssi"
			case .stationRssiWarning:
				return "device_info_station_rssi_warning"
			case .stationRssiError:
				return "device_info_station_rssi_error"
			case .photoVerificationEmptyText:
				return "device_info_photo_verification_empty_text"
			case .photoVerificationStartButtonTitle:
				return "device_info_photo_verification_start_button_title"
			case .photoVerificationUploadingDescription:
				return "device_info_photo_verification_uploading_description"
			case .photoVerificationWithPhotosDescription:
				return "device_info_photo_verification_with_photos_description"
			case .gsmSignal:
				return "device_info_gsm_signal"
			case .gwFrequency:
				return "device_info_gw_frequency"
			case .externalSim:
				return "device_info_external_sim"
			case .iccid:
				return "device_info_iccid"
			case .mobileCountryCode:
				return "device_info_mobile_country_code"
			case .gwBatteryState:
				return "device_info_gw_battery_state"
			case .signalGwStation:
				return "device_info_signal_gw_station"
			case .nextServerCommunication:
				return "device_info_next_server_communication"
			case .stationId:
				return "device_info_station_id"
			case .signalStationGw:
				return "device_info_signal_station_gw"
			case .mobileCountryNetworkCode:
				return "device_info_mobile_country_network_code"
			case .isInUse:
				return "device_info_is_in_use"
		}
	}
}
