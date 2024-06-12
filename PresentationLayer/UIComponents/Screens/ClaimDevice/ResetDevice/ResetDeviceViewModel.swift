//
//  ResetDeviceViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 28/5/24.
//

import Foundation
import Toolkit

class ResetDeviceViewModel: ObservableObject {
	@Published var resetToggle: Bool = false
	
	let completion: VoidCallback
	var bullets: [ClaimDeviceBulletView.Bullet] {
		[.init(fontIcon: .circleOne, text: LocalizableString.ClaimDevice.resetSection1Markdown.localized.attributedMarkdown ?? ""),
		 .init(fontIcon: .circleTwo, text: LocalizableString.ClaimDevice.resetSection2Markdown.localized.attributedMarkdown ?? "")]
	}

	init(completion: @escaping VoidCallback) {
		self.completion = completion
	}

	func handleButtonTap() {
		completion()
	}
}
