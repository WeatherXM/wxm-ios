//
//  Localizable+Boosts.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 6/3/24.
//

import Foundation

extension LocalizableString {
	enum Boosts {
		case boostTokensEarned(String)
		case dailyBoostScore
		case lostTokens(String)
	}
}

extension LocalizableString.Boosts: WXMLocalizable {
	var localized: String {
		var localized = NSLocalizedString(key, comment: "")
		switch self {
			case .boostTokensEarned(let text), .lostTokens(let text):
				localized = String(format: localized, text)
			default: break
		}

		return localized

	}

	var key: String {
		switch self {
			case .boostTokensEarned:
				"boosts_tokens_earned_format"
			case .dailyBoostScore:
				"boosts_daily_boost_score"
			case .lostTokens:
				"boosts_lost_tokens_format"
		}
	}
}
