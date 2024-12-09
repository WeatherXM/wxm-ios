//
//  PhotoIntroViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 4/12/24.
//

import Foundation

@MainActor
class PhotoIntroViewModel: ObservableObject {
	@Published var isTermsAccepted: Bool = false
	lazy var instructions: [PhotoIntroView.Instruction] = {
		[.init(icon: .iconRotate, text: LocalizableString.PhotoVerification.rotateInstruction.localized, bullets: []),
		 .init(icon: .iconSurface, text: LocalizableString.PhotoVerification.surfaceInstruction.localized, bullets: []),
		 .init(icon: .iconNoFaces, text: LocalizableString.PhotoVerification.noFacesInstruction.localized, bullets: []),
		 .init(icon: .iconMaxPhotos,
			   text: LocalizableString.PhotoVerification.maxPhotosInstruction.localized,
			   bullets: [LocalizableString.PhotoVerification.maxPhotosInstructionBullet0.localized,
						 LocalizableString.PhotoVerification.maxPhotosInstructionBullet1.localized,
						 LocalizableString.PhotoVerification.maxPhotosInstructionBullet2.localized,
						 LocalizableString.PhotoVerification.maxPhotosInstructionBullet3.localized])]
	}()

	lazy var recommendedExamples: (title: String, examples: [PhotoIntroExamplesView.Example]) = {
		(LocalizableString.PhotoVerification.yourPhotoShouldLook.localized, Self.getRecommendedExamples())
	}()

	lazy var faultExamples: (title: String, examples: [PhotoIntroExamplesView.Example]) = {
		(LocalizableString.PhotoVerification.notLikeThis.localized, Self.getFaultExamples())
	}()

	func handleBeginButtonTap() {
	}
}

extension PhotoIntroViewModel: HashableViewModel {
	nonisolated func hash(into hasher: inout Hasher) {
	}
}

private extension PhotoIntroViewModel {
	static func getRecommendedExamples() -> [PhotoIntroExamplesView.Example] {
		[.init(image: .recommendedInstallation0,
			   bullets: [LocalizableString.PhotoVerification.checkFromTheRainGauge.localized,
						 LocalizableString.PhotoVerification.checkClearViewOfTheHorizon.localized,
						 LocalizableString.PhotoVerification.checkGoodDistance.localized]),
		 .init(image: .recommendedInstallation1,
			   bullets: [LocalizableString.PhotoVerification.checkFromTheAnemometer.localized,
						 LocalizableString.PhotoVerification.checkShowingTheSurface.localized,
						 LocalizableString.PhotoVerification.checkShowingPossibleObastacle.localized]),
		 .init(image: .recommendedInstallation2,
			   bullets: [LocalizableString.PhotoVerification.checkFromTheSide.localized,
						 LocalizableString.PhotoVerification.checkClearViewOfTheHorizon.localized,
						 LocalizableString.PhotoVerification.checkSubject.localized]),
		 .init(image: .recommendedInstallation3,
			   bullets: [LocalizableString.PhotoVerification.checkFromTheOtherSide.localized])]
	}

	static func getFaultExamples() -> [PhotoIntroExamplesView.Example] {
		[.init(image: .wrongInstallation0,
			   bullets: [LocalizableString.PhotoVerification.faultFacingBottomUp.localized,
						 LocalizableString.PhotoVerification.faultNotShowingSurroundings.localized,
						 LocalizableString.PhotoVerification.faultTooClose.localized]),
		 .init(image: .wrongInstallation1,
			   bullets: [LocalizableString.PhotoVerification.faultNotShowingPossibleObstacles.localized,
						 LocalizableString.PhotoVerification.faultNoSurface.localized]),
		 .init(image: .wrongInstallation2,
			   bullets: [LocalizableString.PhotoVerification.faultTiltedAngle.localized,
						 LocalizableString.PhotoVerification.faultSubjectNotInMiddle.localized])]
	}

}
