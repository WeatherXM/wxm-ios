//
//  PhotoIntroViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 4/12/24.
//

import Foundation

@MainActor
class PhotoIntroViewModel: ObservableObject {

	lazy var instructions: [PhotoIntroView.Instruction] = {
		[.init(icon: .iconRotate,
			   text: LocalizableString.PhotoVerification.rotateInstruction.localized),
		 .init(icon: .iconSurface, text: LocalizableString.PhotoVerification.surfaceInstruction.localized),
		 .init(icon: .iconNoFaces, text: LocalizableString.PhotoVerification.noFacesInstruction.localized),
		 .init(icon: .iconMaxPhotos, text: LocalizableString.PhotoVerification.maxPhotosInstruction.localized)]
	}()
}
