//
//  LocalizableString+UpdateFirmware.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 4/9/23.
//

import Foundation

extension LocalizableString {
    enum FirmwareUpdate: WXMLocalizable {
        case title
        case titleConnecting
        case titleDownloading
        case titleInstalling
        case descriptionDownloading
        case descriptionInstalling
        case stepDownload
        case stepInstall
        case successTitle
        case successDescription
        case successButtonTitle
        case failureTitle
        case failedConnectionTitle
        case failureDescription(String)
        case failedStationConnectionDescription(String, String)
        case failureButtonTitle
        case stationNotInRangeTitle
        case stationNotInRangeDescription
        case downloadFileError
        case failedToConnectError
        case installError(String)

        var localized: String {
            var localized = NSLocalizedString(self.key, comment: "")
            switch self {
                case .failureDescription(let text), .installError(let text):
                    localized = String(format: localized, text)
                case .failedStationConnectionDescription(let text, let text1):
                    localized = String(format: localized, text, text1)
                default:
                    break
            }

            return localized
        }

        var key: String {
            switch self {
                case .title:
                    return "firmware_update_title"
                case .titleConnecting:
                    return "firmware_update_title_connecting"
                case .titleDownloading:
                    return "firmware_update_title_downloading"
                case .titleInstalling:
                    return "firmware_update_title_installing"
                case .descriptionDownloading:
                    return "firmware_update_description_downloading"
                case .descriptionInstalling:
                    return "firmware_update_description_installing"
                case .stepDownload:
                    return "firmware_update_step_download"
                case .stepInstall:
                    return "firmware_update_step_install"
                case .successTitle:
                    return "firmware_update_success_title"
                case .successDescription:
                    return "firmware_update_success_description"
                case .successButtonTitle:
                    return "firmware_update_success_button_title"
                case .failureTitle:
                    return "firmware_update_failure_title"
                case .failedConnectionTitle:
                    return "firmware_update_failed_connection_title"
                case .failureDescription:
                    return "firmware_update_failure_description_format"
                case .failedStationConnectionDescription:
                    return "failed_station_connection_description_format"
                case .failureButtonTitle:
                    return "firmware_update_failure_button_title"
                case .stationNotInRangeTitle:
                    return "station_not_in_range_title"
                case .stationNotInRangeDescription:
                    return "station_not_in_range_description"
                case .downloadFileError:
                    return "firmware_update_download_file_error"
                case .failedToConnectError:
                    return "failed_to_connect_error"
                case .installError:
                    return "firmware_update_install_error_format"
            }
        }
    }
}
