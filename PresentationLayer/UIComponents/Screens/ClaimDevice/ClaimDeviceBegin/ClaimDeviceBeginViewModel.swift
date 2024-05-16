//
//  ClaimDeviceBeginViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 30/4/24.
//

import Foundation
import Toolkit

class ClaimDeviceBeginViewModel: ObservableObject {
	let completion: VoidCallback
	var videoLink: String? {
		nil
	}
	var bullets: [ClaimDeviceBeginView.Bullet] {
		[.init(fontIcon: .circleOne, text: LocalizableString.ClaimDevice.connectD1BulletOne.localized.attributedMarkdown ?? ""),
		 .init(fontIcon: .circleTwo, text: LocalizableString.ClaimDevice.connectD1BulletTwo.localized.attributedMarkdown ?? ""),
		 .init(fontIcon: .circleThree, text: LocalizableString.ClaimDevice.connectD1BulletThree.localized.attributedMarkdown ?? ""),
		 .init(fontIcon: .circleFour, text: LocalizableString.ClaimDevice.connectD1BulletFour.localized.attributedMarkdown ?? "")]
	}

	init(completion: @escaping VoidCallback) {
		self.completion = completion
	}

	func handleButtonTap() {
		completion()
	}
}

class ClaimDeviceM5BeginViewModel: ClaimDeviceBeginViewModel {
	override var bullets: [ClaimDeviceBeginView.Bullet] { 
		[.init(fontIcon: .circleOne, text: LocalizableString.ClaimDevice.connectM5BulletOne.localized.attributedMarkdown ?? ""),
		 .init(fontIcon: .circleTwo, text: LocalizableString.ClaimDevice.connectM5BulletTwo.localized.attributedMarkdown ?? ""),
		 .init(fontIcon: .circleThree, text: LocalizableString.ClaimDevice.connectM5BulletThree.localized.attributedMarkdown ?? ""),
		 .init(fontIcon: .circleFour, text: LocalizableString.ClaimDevice.connectM5BulletFour.localized.attributedMarkdown ?? "")]
	}

	override var videoLink: String? {
		DisplayedLinks.m5VideoLink.linkURL
	}
}
