//
//  LocalizableString+ClaimDevice.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 5/9/23.
//

import Foundation

extension LocalizableString {
    enum ClaimDevice {
        case selectType
        case typeWS1000Title
        case typeWS1000Subtitle
        case typeWS2000Title
        case typeWS2000Subtitle
        case ws1000DeviceTitle
        case ws2000DeviceTitle
        case resetStepTitle
        case bluetoothTitle
        case locationStepTitle
        case enterSerialNumberTitle
        case frequencyStepTitle
        case connectionStepTitle
        case verifyStepTitle
        case selectDeviceTitle
        case selectDeviceDescription
        case manuallyButton
        case scanningForWXMDevices
        case scanAgain
        case deviceHelium
        case deviceId(String)
        case verifyTitle
        case devEUIFieldHint
        case keyFieldHint
        case information(String)
        case informationBold
        case resetStationTitle
        case resetSection1
        case resetSection1Markdown
        case resetSection2
        case resetSection2Markdown
        case verifyButton
        case heliumInvalidEUIKey
        case iVeResetMyDeviceButton
        case iVeConnectMyM5Button
        case confirmLocationTitle
        case locationAcknowledgeText
        case confirmLocationConfirmAndClaim
        case confirmLocationSearchHint
        case confirmLocationNoAccessToServicesTitle
        case confirmLocationNoAccessToServicesText
        case claimingTitle
        case claimingText(String)
        case claimingTextInformation
        case successTitle
        case successText(String)
        case failedTitle
        case connectionFailedTitle
        case failedText(String, String)
        case connectionFailedText(String, String)
        case connectionFailedMarkDownText(String, String)
        case failedTextLinkURL
        case failedTextLinkTitle
        case failedTroubleshootingTextLinkTitle
        case viewStationButton
        case retryClaimButton
        case cancelClaimButton
        case updateFirmwareButton
        case updateFirmwareInfoMarkdown
        case updateFirmwareAlertTitle
        case updateFirmwareAlertText
        case updateFirmwareAlertGoToStation
        case updateFirmwareAlertUpdate
        case errorInvalidId
        case errorInvalidIdM5
        case errorInvalidLocation
        case alreadyClaimed
        case notFound
        case claimingError
        case claimingErrorM5
        case errorNoInternet
        case errorConnectionTimeOut
        case errorGeneric
        case connectionTitle
        case connectionBullet1(String)
        case connectionBullet1Bold
        case connectionBullet2(String)
        case connectionBullet2Bold
        case connectionBullet3
        case connectionText
        case stepSettingFrequency
        case stepClaiming

    }
}

extension LocalizableString.ClaimDevice: WXMLocalizable {
    var localized: String {
        var localized = NSLocalizedString(self.key, comment: "")
        switch self {
            case .deviceId(let text),
                    .information(let text),
                    .claimingText(let text),
                    .successText(let text),
                    .connectionBullet1(let text),
                    .connectionBullet2(let text):
                localized = String(format: localized, text)
            case .failedText(let text, let text1),
                    .connectionFailedText(let text, let text1),
                    .connectionFailedMarkDownText(let text, let text1):
                localized = String(format: localized, text, text1)
            default:
                break
        }

        return localized
    }

    var key: String {
        switch self {
            case .selectType:
                return "claim_device_select_type"
            case .typeWS1000Title:
                return "claim_device_type_ws1000_title"
            case .typeWS1000Subtitle:
                return "claim_device_type_ws1000_subtitle"
            case .typeWS2000Title:
                return "claim_device_type_ws2000_title"
            case .typeWS2000Subtitle:
                return "claim_device_type_ws2000_subtitle"
            case .ws1000DeviceTitle:
                return "claim_device_ws1000_device_title"
            case .ws2000DeviceTitle:
                return "claim_device_ws2000_device_title"
            case .resetStepTitle:
                return "claim_device_reset_step_title"
            case .bluetoothTitle:
                return "claim_device_bluetooth_title"
            case .locationStepTitle:
                return "claim_device_location_step_title"
            case .enterSerialNumberTitle:
                return "claim_device_enter_serial_number_title"
            case .frequencyStepTitle:
                return "claim_device_frequncy_step_title"
            case .connectionStepTitle:
                return "claim_device_connection_step_title"
            case .verifyStepTitle:
                return "claim_device_verify_step_title"
            case .selectDeviceTitle:
                return "claim_device_select_device_title"
            case .selectDeviceDescription:
                return "claim_device_select_device_description"
            case .manuallyButton:
                return "claim_device_manually_button"
            case .scanningForWXMDevices:
                return "claim_device_scanning_for_wxm_devices"
            case .scanAgain:
                return "claim_device_scan_again"
            case .deviceHelium:
                return "claim_device_device_helium"
            case .deviceId:
                return "claim_device_device_id_format"
            case .verifyTitle:
                return "claim_device_verify_title"
            case .devEUIFieldHint:
                return "claim_device_dev_EUI_field_hint"
            case .keyFieldHint:
                return "claim_device_key_field_hint"
            case .information:
                return "claim_device_information_format"
            case .informationBold:
                return "claim_device_information_bold"
            case .resetStationTitle:
                return "claim_device_reset_station_title"
            case .resetSection1:
                return "claim_device_reset_section_1"
            case .resetSection1Markdown:
                return "claim_device_reset_section_1_markdown"
            case .resetSection2:
                return "claim_device_reset_section_2"
            case .resetSection2Markdown:
                return "claim_device_reset_section_2_markdown"
            case .verifyButton:
                return "claim_device_verify_button"
            case .heliumInvalidEUIKey:
                return "claim_device_helium_invalid_eui_key"
            case .iVeResetMyDeviceButton:
                return "claim_device_i_ve_reset_my_device_button"
            case .iVeConnectMyM5Button:
                return "claim_device_i_ve_connect_my_m5_button"
            case .confirmLocationTitle:
                return "claim_device_confirm_location_title"
            case .locationAcknowledgeText:
                return "claim_device_location_acknowledge_text"
            case .confirmLocationConfirmAndClaim:
                return "claim_device_confirm_location_confirm_and_claim"
            case .confirmLocationSearchHint:
                return "claim_device_confirm_location_search_hint"
            case .confirmLocationNoAccessToServicesTitle:
                return "claim_device_confirm_location_no_access_to_services_title"
            case .confirmLocationNoAccessToServicesText:
                return "claim_device_confirm_location_no_access_to_services_text"
            case .claimingTitle:
                return "claim_device_claiming_title"
            case .claimingText:
                return "claim_device_claiming_text_format"
            case .claimingTextInformation:
                return "claim_device_claiming_text_information"
            case .successTitle:
                return "claim_device_success_title"
            case .successText:
                return "claim_device_success_text_format"
            case .failedTitle:
                return "claim_device_failed_title"
            case .connectionFailedTitle:
                return "claim_device_connection_failed_title"
            case .failedText:
                return "claim_device_failed_text_format"
            case .connectionFailedText:
                return "claim_device_connection_failed_text_format"
            case .connectionFailedMarkDownText:
                return "claim_device_connection_failed_markdown_text_format"
            case .failedTextLinkURL:
                return "claim_device_failed_text_link_url"
            case .failedTextLinkTitle:
                return "claim_device_failed_text_link_title"
            case .failedTroubleshootingTextLinkTitle:
                return "claim_device_failed_troubleshooting_text_link_title"
            case .viewStationButton:
                return "claim_device_view_station_button"
            case .retryClaimButton:
                return "claim_device_retry_claim_button"
            case .cancelClaimButton:
                return "claim_device_cancel_claim_button"
            case .updateFirmwareButton:
                return "claim_device_update_firmware_button"
            case .updateFirmwareInfoMarkdown:
                return "claim_device_update_firmware_info_markdown"
            case .updateFirmwareAlertTitle:
                return "claim_device_update_firmware_alert_title"
            case .updateFirmwareAlertText:
                return "claim_device_update_firmware_alert_text"
            case .updateFirmwareAlertGoToStation:
                return "claim_device_update_firmware_alert_go_to_station"
            case .updateFirmwareAlertUpdate:
                return "claim_device_update_firmware_alert_update"
            case .errorInvalidId:
                return "claim_device_error_invalid_id"
            case .errorInvalidIdM5:
                return "claim_device_error_invalid_id_m5"
            case .errorInvalidLocation:
                return "claim_device_error_invalid_location"
            case .alreadyClaimed:
                return "claim_device_alread_claimed"
            case .notFound:
                return "claim_device_not_found"
            case .claimingError:
                return "claim_device_claiming_error"
            case .claimingErrorM5:
                return "claim_device_claiming_error_m5"
            case .errorNoInternet:
                return "claim_device_error_no_internet"
            case .errorConnectionTimeOut:
                return "claim_device_error_connection_time_out"
            case .errorGeneric:
                return "claim_device_error_generic"

            case .connectionTitle:
                return "claim_device_connection_title"
            case .connectionBullet1:
                return "claim_device_connection_bullet_1_format"
            case .connectionBullet1Bold:
                return "claim_device_connection_bullet_1_bold"
            case .connectionBullet2:
                return "claim_device_connection_bullet_2_format"
            case .connectionBullet2Bold:
                return "claim_device_connection_bullet_2_bold"
            case .connectionBullet3:
                return "claim_device_connection_bullet_3"
            case .connectionText:
                return "claim_device_connection_text"
            case .stepSettingFrequency:
                return "claim_device_step_setting_frequency"
            case .stepClaiming:
                return "claim_device_step_claiming"
        }
    }
}
