//
//  LocalizableString+DeleteAccount.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 6/9/23.
//

import Foundation

extension LocalizableString {
    enum DeleteAccount {
        case successfulTitle
        case failureTitle
        case successfulText
        case goToSignInText
        case takeSurveyText
        case cancelDeletion
        case retryDeletion
        case removingAccount
        case deleteAccount
        case textMarkdown
        case understandDeletionTerms
        case generalInfo
        case moreInfoLink
        case toDeleteTitle
        case contactForSupport
        case noCollectDataTitle
        case notDeleteRewards
        case notDeleteWeatherData
        case notDeleteTitle
        case toDeletePersonalData
        case toDeleteAddress
        case toDeleteName
        case failedContactSupport(String)
        case failedDescription
    }
}

extension LocalizableString.DeleteAccount: WXMLocalizable {
    var localized: String {
        var localized = NSLocalizedString(key, comment: "")
        switch self {
            case .failedContactSupport(let text):
                localized = String(format: localized, text)
            default:
                break
        }

        return localized
    }

    var key: String {
        switch self {
            case .successfulTitle:
                return "delete_account_successful_title"
            case .failureTitle:
                return "delete_account_failure_title"
            case .successfulText:
                return "delete_account_successful_text"
            case .goToSignInText:
                return "delete_account_go_to_sign_in_text"
            case .takeSurveyText:
                return "delete_account_take_survey_text"
            case .cancelDeletion:
                return "delete_account_cancel_deletion"
            case .retryDeletion:
                return "delete_account_retry_deletion"
            case .removingAccount:
                return "delete_account_removing_account"
            case .deleteAccount:
                return "delete_account_delete_account"
            case .textMarkdown:
                return "delete_account_text_markdown"
            case .understandDeletionTerms:
                return "delete_account_understand_deletion_terms"
            case .generalInfo:
                return "delete_account_general_info"
            case .moreInfoLink:
                return "delete_account_more_info_link"
            case .toDeleteTitle:
                return "delete_account_to_delete_title"
            case .contactForSupport:
                return "delete_account_contact_support"
            case .noCollectDataTitle:
                return "delete_account_no_collect_data_title"
            case .notDeleteRewards:
                return "delete_account_not_delete_rewards"
            case .notDeleteWeatherData:
                return "delete_account_not_delete_weather_data"
            case .notDeleteTitle:
                return "delete_account_not_delete_title"
            case .toDeletePersonalData:
                return "delete_account_to_delete_personal_data"
            case .toDeleteAddress:
                return "delete_account_to_delete_address"
            case .toDeleteName:
                return "delete_account_to_delete_name"
            case .failedContactSupport:
                return "delete_account_failed_contact_support_format"
            case .failedDescription:
                return "delete_account_failed_description"
        }
    }
}
