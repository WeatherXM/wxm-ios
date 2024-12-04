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
		case rotateInstruction
		case surfaceInstruction
		case noFacesInstruction
		case maxPhotosInstruction
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
			case .rotateInstruction:
				"photo_verification_rotate_instruction"
			case .surfaceInstruction:
				"photo_verification_surface_instruction"
			case .noFacesInstruction:
				"photo_verification_no_faces_instruction"
			case .maxPhotosInstruction:
				"photo_verification_max_photos_instruction"
		}
	}
}
