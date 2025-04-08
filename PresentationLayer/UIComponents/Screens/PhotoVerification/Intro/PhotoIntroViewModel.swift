//
//  PhotoIntroViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 4/12/24.
//

import Foundation
import DomainLayer
import SwiftUI
import Toolkit

@MainActor
class PhotoIntroViewModel: ObservableObject {
	@Published var areTermsAccepted: Bool {
		didSet {
			photoGalleryUseCase.setTermsAccepted(areTermsAccepted)
		}
	}

	var closeButtonIcon: FontIcon { .xmark }
	var showTerms: Bool { true }
	lazy var instructions: [PhotoIntroView.Instruction] = {
		[.init(icon: .iconRotate, text: LocalizableString.PhotoVerification.rotateInstruction.localized, bullets: []),
		 .init(icon: .iconZoom, text: LocalizableString.PhotoVerification.zoomInstruction.localized, bullets: []),
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

	private let deviceId: String
	private let images: [String]
	private let photoGalleryUseCase: PhotoGalleryUseCaseApi

	init(deviceId: String, images: [String], photoGalleryUseCase: PhotoGalleryUseCaseApi) {
		self.deviceId = deviceId
		self.images = images
		self.photoGalleryUseCase = photoGalleryUseCase
		areTermsAccepted = photoGalleryUseCase.areTermsAccepted
	}

	func handleBeginButtonTap(dismiss: DismissAction) {
		dismiss()
		let viewModel = ViewModelsFactory.getGalleryViewModel(deviceId: deviceId, images: images, isNewVerification: true)
		Router.shared.navigateTo(.photoGallery(viewModel))
	}

	func handleOnAppear() {
		WXMAnalytics.shared.trackScreen(.stationPhotosIntro)
	}
}

extension PhotoIntroViewModel: HashableViewModel {
	nonisolated func hash(into hasher: inout Hasher) {
	}

	@MainActor
	static func startPhotoVerification(deviceId: String, images: [String], isNewPhotoVerification: Bool) {
		let useCase = SwinjectHelper.shared.getContainerForSwinject().resolve(PhotoGalleryUseCaseApi.self)!
		let areTermsAccepted = useCase.areTermsAccepted

		if areTermsAccepted {
			let viewModel = ViewModelsFactory.getGalleryViewModel(deviceId: deviceId,
																  images: images,
																  isNewVerification: isNewPhotoVerification)
			Router.shared.navigateTo(.photoGallery(viewModel))
			return
		}

		let viewModel = ViewModelsFactory.getPhotoIntroViewModel(deviceId: deviceId, images: images)
		Router.shared.showFullScreen(.photoIntro(viewModel))
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

class PhotoInstructionsViewModel: PhotoIntroViewModel {
	override var closeButtonIcon: FontIcon { .arrowLeft }
	override var showTerms: Bool { false }

	override func handleOnAppear() {
		WXMAnalytics.shared.trackScreen(.stationPhotosInstructions)
	}
}
