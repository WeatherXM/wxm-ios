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
		case photoExamples
		case yourPhotoShouldLook
		case checkFromTheRainGauge
		case checkClearViewOfTheHorizon
		case checkGoodDistance
		case checkFromTheAnemometer
		case checkShowingTheSurface
		case checkShowingPossibleObastacle
		case checkFromTheSide
		case checkClearView
		case checkSubject
		case checkFromTheOtherSide
		case notLikeThis
		case faultFacingBottomUp
		case faultNotShowingSurroundings
		case faultTooClose
		case faultNotShowingPossibleObstacles
		case faultNoSurface
		case faultTiltedAngle
		case faultSubjectNotInMiddle
		case uploadPhotos
		case uploadPhotosDescription
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
			case .photoExamples:
				"photo_verification_photo_examples"
			case .yourPhotoShouldLook:
				"photo_verification_your_photo_should_look"
			case .checkFromTheRainGauge:
				"photo_verification_check_from_the_rain_gauge"
			case .checkClearViewOfTheHorizon:
				"photo_verification_check_clear_view_of_the_horizon"
			case .checkGoodDistance:
				"photo_verification_check_good_distance"
			case .checkFromTheAnemometer:
				"photo_verification_check_from_the_anemometer"
			case .checkShowingTheSurface:
				"photo_verification_check_showing_the_surface"
			case .checkShowingPossibleObastacle:
				"photo_verification_check_showing_possible_obastacle"
			case .checkFromTheSide:
				"photo_verification_check_from_the_side"
			case .checkClearView:
				"photo_verification_check_clear_view"
			case .checkSubject:
				"photo_verification_check_subject"
			case .checkFromTheOtherSide:
				"photo_verification_check_from_the_other_side"
			case .notLikeThis:
				"photo_verification_not_like_this"
			case .faultFacingBottomUp:
				"photo_verification_fault_facing_bottom_up"
			case .faultNotShowingSurroundings:
				"photo_verification_fault_not_showing_surroundings"
			case .faultTooClose:
				"photo_verification_fault_too_close"
			case .faultNotShowingPossibleObstacles:
				"photo_verification_fault_not_showing_possible_obstacles"
			case .faultNoSurface:
				"photo_verification_fault_no_surface"
			case .faultTiltedAngle:
				"photo_verification_fault_tilted_angle"
			case .faultSubjectNotInMiddle:
				"photo_verification_fault_subject_not_in_middle"
			case .uploadPhotos:
				"photo_verification_upload_photos"
			case .uploadPhotosDescription:
				"photo_verification_upload_photos_description"
		}
	}
}
