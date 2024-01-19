//
//  LocalizableString+SelectFrequency.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 14/9/23.
//

import Foundation

extension LocalizableString {
    enum SelectFrequency {
        case title
        case text
        case listLink(String)
        case listLinkText
        case acknowledgeText
        case subtitle
        case selectedFromCountry(String)
        case selectedFromLocation
        case selectedFromLocationDescription(String)
        case settingFailedTitle
        case settingFailedText
        case quitClaimingButton
        case tryAgainButton
    }
}

extension LocalizableString.SelectFrequency: WXMLocalizable {
    var localized: String {
        var localized = NSLocalizedString(self.key, comment: "")
        switch self {
            case .listLink(let text),
                    .selectedFromCountry(let text),
                    .selectedFromLocationDescription(let text):
                localized = String(format: localized, text)
            default:
                break
        }

        return localized
    }

    var key: String {
        switch self {
            case .title:
                return "select_frequency_title"
            case .text:
                return "select_frequency_text"
            case .listLink:
                return "select_frequency_link_format"
            case .listLinkText:
                return "select_frequency_list_link"
            case .acknowledgeText:
                return "select_frequency_acknowledge_text"
            case .subtitle:
                return "select_frequency_subtitle"
            case .selectedFromCountry:
                return "select_frequency_selected_from_country_format"
            case .selectedFromLocation:
                return "select_frequency_selected_from_location"
            case .selectedFromLocationDescription:
                return "select_frequency_selected_from_location_description_format"
            case .settingFailedTitle:
                return "select_frequency_setting_failed_title"
            case .settingFailedText:
                return "select_frequency_setting_failed_text"
            case .quitClaimingButton:
                return "select_frequency_quit_claiming_button"
            case .tryAgainButton:
                return "select_frequency_try_again_button"
        }
    }
}
