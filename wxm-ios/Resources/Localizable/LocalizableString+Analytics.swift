//
//  LocalizableString+Analytics.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 6/9/23.
//

import Foundation

extension LocalizableString {
    enum Analytics {
        case title
        case description
        case whatWeCollect
        case whatWeDontCollect
        case appUsage
        case systemVerion
        case personalData
        case identifyingInfo
        case caption
    }
}

extension LocalizableString.Analytics: WXMLocalizable {
    var localized: String {
        NSLocalizedString(key, comment: "")
    }
    
    var key: String {
        switch self {
            case .title:
                return "analytics_title"
            case .description:
                return "analytics_description"
            case .whatWeCollect:
                return "analytics_what_we_collect"
            case .whatWeDontCollect:
                return "analytics_what_we_do_not_collect"
            case .appUsage:
                return "analytics_app_usage"
            case .systemVerion:
                return "analytics_system_version"
            case .personalData:
                return "analytics_personal_data"
            case .identifyingInfo:
                return "analytics_identifying_info"
            case .caption:
                return "analytics_caption"
        }
    }
}
