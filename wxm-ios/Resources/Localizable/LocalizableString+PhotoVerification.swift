//
//  LocalizableString+PhotoVerification.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 4/12/24.
//

import Foundation

extension LocalizableString {
	enum PhotoVerification {
		case allAbout
		case photoVerificationIntroTitle
		case boostNetworkDescription
		case howToTakePhoto
	}
}

extension LocalizableString.PhotoVerification: WXMLocalizable {
	var localized: String {
		let localized = NSLocalizedString(key, comment: "")
		return localized
	}

	var key: String {
		switch self {

			case .allAbout:
				"photo_verification_all_about"
			case .photoVerificationIntroTitle:
				"photo_verification_intro_title"
			case .boostNetworkDescription:
				"photo_verification_boost_network_description"
			case .howToTakePhoto:
				"photo_verification_how_to_take_photo"
		}
	}
}
