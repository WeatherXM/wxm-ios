//
//  ClaimDeviceBeforeBeginViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 11/7/25.
//

import Foundation

class ClaimDeviceBeforeBeginViewModel: ObservableObject {
	var fistSectionBullets: [ClaimDeviceBulletView.Bullet] {
		[.init(fontIcon: .circleOne, text: LocalizableString.ClaimDevice.beforeBeginBulletOne.localized.attributedMarkdown ?? ""),
		 .init(fontIcon: .circleTwo, text: LocalizableString.ClaimDevice.beforeBeginBulletTwo.localized.attributedMarkdown ?? ""),
		 .init(fontIcon: .circleThree, text: LocalizableString.ClaimDevice.beforeBeginBulletThree.localized.attributedMarkdown ?? "")]
	}

	var secondSectionBullets: [ClaimDeviceBulletView.Bullet] {
		[.init(fontIcon: .circleFour, text: LocalizableString.ClaimDevice.beforeBeginBulletFour.localized.attributedMarkdown ?? ""),
		 .init(fontIcon: .circleFive, text: LocalizableString.ClaimDevice.beforeBeginBulletFive.localized.attributedMarkdown ?? ""),
		 .init(fontIcon: .circleSix, text: LocalizableString.ClaimDevice.beforeBeginBulletSix.localized.attributedMarkdown ?? ""),
		 .init(fontIcon: .circleSeven, text: LocalizableString.ClaimDevice.beforeBeginBulletSeven.localized.attributedMarkdown ?? "")]
	}

}
