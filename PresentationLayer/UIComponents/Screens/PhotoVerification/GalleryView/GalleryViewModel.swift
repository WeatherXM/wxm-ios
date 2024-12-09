//
//  GalleryViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 9/12/24.
//

import Foundation

@MainActor
class GalleryViewModel: ObservableObject {
	@Published var subtitle: String? = ""

	init() {
		updateSubtitle()
	}
}

private extension GalleryViewModel {
	func updateSubtitle() {
		subtitle = LocalizableString.PhotoVerification.morePhotosToUpload(2).localized
	}
}
