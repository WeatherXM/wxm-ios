//
//  NetworkDeviceIDTokensTransactionsResponse+.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 21/3/23.
//

import Foundation
import DomainLayer
import Toolkit

func getHexagonColor(validationScore: Double?) -> ColorEnum {
    guard let validationScore else {
        return .reward_score_unknown
    }

    switch validationScore {
        case 0.0 ..< 0.2:
            return .reward_score_very_low
        case 0.2 ..< 0.4:
            return .reward_score_low
        case 0.4 ..< 0.6:
            return .reward_score_average
        case 0.6 ..< 0.8:
            return .reward_score_high
        case 0.8 ... 1.0:
            return .reward_score_very_high
        default:
            return .reward_score_unknown
    }
}
