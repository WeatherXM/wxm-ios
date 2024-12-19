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
		case maxPhotosInstructionBullet0
		case maxPhotosInstructionBullet1
		case maxPhotosInstructionBullet2
		case maxPhotosInstructionBullet3
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
		case letsTakeTheFirstPhoto
		case stationPhotos
		case morePhotosToUpload(Int)
		case upload
		case instructions
		case tapThePlusButton
		case yourCameraWillOpen
		case allowAccess
		case openSettings
		case exitPhotoVerification
		case exitPhotoVerificationText
		case exitPhotoVerificationMinimumPhotosText
		case uploading
		case cancelUpload
		case retryUpload
		case uploadErrorDescription
	}
}

extension LocalizableString.PhotoVerification: WXMLocalizable {
	var localized: String {
		var localized = NSLocalizedString(key, comment: "")
		switch self {
			case .morePhotosToUpload(let count):
				localized = String(format: localized, count)
			default: break
		}

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
			case .maxPhotosInstructionBullet0:
				"photo_verification_max_photos_instruction_bullet_0"
			case .maxPhotosInstructionBullet1:
				"photo_verification_max_photos_instruction_bullet_1"
			case .maxPhotosInstructionBullet2:
				"photo_verification_max_photos_instruction_bullet_2"
			case .maxPhotosInstructionBullet3:
				"photo_verification_max_photos_instruction_bullet_3"
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
			case .letsTakeTheFirstPhoto:
				"photo_verification_lets_take_the_first_photo"
			case .stationPhotos:
				"photo_verification_station_photos"
			case .morePhotosToUpload(let count):
				count == 1 ? "photo_verification_more_photos_to_upload_singular" : "photo_verification_more_photos_to_upload_plural"
			case .upload:
				"photo_verification_upload"
			case .instructions:
				"photo_verification_instructions"
			case .tapThePlusButton:
				"photo_verification_tap_the_plus_button"
			case .yourCameraWillOpen:
				"photo_verification_your_camera_will_open"
			case .allowAccess:
				"photo_verification_allow_access"
			case .openSettings:
				"photo_verification_open_settings"
			case .exitPhotoVerification:
				"photo_verification_exit_photo_verification"
			case .exitPhotoVerificationText:
				"photo_verification_exit_photo_verification_text"
			case .exitPhotoVerificationMinimumPhotosText:
				"photo_verification_exit_photo_verification_minimum_photos_text"
			case .uploading:
				"photo_verification_uploading"
			case .cancelUpload:
				"photo_verification_cancel_upload"
			case .retryUpload:
				"photo_verification_retry_upload"
			case .uploadErrorDescription:
				"photo_verification_upload_error_description"
		}
	}
}
