//
//  ClaimDevicePhotoIntroViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 14/7/25.
//

import Foundation
import SwiftUI
import Toolkit

class ClaimDevicePhotoIntroViewModel: PhotoIntroViewModel {
	var completion: VoidCallback?

	override func handleOnAppear() {}

	override func handleBeginButtonTap(dismiss: DismissAction) {
		completion?()
	}
}
