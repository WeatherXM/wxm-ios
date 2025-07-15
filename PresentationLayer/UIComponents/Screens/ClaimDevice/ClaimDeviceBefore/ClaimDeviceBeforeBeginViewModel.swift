//
//  ClaimDeviceBeforeBeginViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 11/7/25.
//

import Foundation
import Toolkit

class ClaimDeviceBeforeBeginViewModel: ObservableObject {
	let completion: VoidCallback
	var fistSectionBullets: [ClaimDeviceBulletView.Bullet] {
		[.init(fontIcon: .circleOne, text: LocalizableString.ClaimDevice.beforeBeginCheckBox.localized.attributedMarkdown ?? ""),
		 .init(fontIcon: .circleTwo, text: LocalizableString.ClaimDevice.beforeBeginAssembleStation.localized.attributedMarkdown ?? ""),
		 .init(fontIcon: .circleThree, text: LocalizableString.ClaimDevice.beforeBeginInstallStation.localized.attributedMarkdown ?? "")]
	}

	var secondSectionBullets: [ClaimDeviceBulletView.Bullet] {
		[.init(fontIcon: .circleFour, text: LocalizableString.ClaimDevice.beforeBeginConnectGateway.localized.attributedMarkdown ?? ""),
		 .init(fontIcon: .circleFive, text: LocalizableString.ClaimDevice.beforeBeginConfirmLocation.localized.attributedMarkdown ?? ""),
		 .init(fontIcon: .circleSix, text: LocalizableString.ClaimDevice.beforeBeginTakePhotos.localized.attributedMarkdown ?? ""),
		 .init(fontIcon: .circleSeven, text: LocalizableString.ClaimDevice.beforeBeginAllDone.localized.attributedMarkdown ?? "")]
	}

	init(completion: @escaping VoidCallback) {
		self.completion = completion
	}

	func handleButtonTap() {
		completion()
	}
}

class ClaimDeviceHeliumBeforeBeginViewModel: ClaimDeviceBeforeBeginViewModel {

	override var fistSectionBullets: [ClaimDeviceBulletView.Bullet] {
		[.init(fontIcon: .circleOne, text: LocalizableString.ClaimDevice.beforeBeginCheckBox.localized.attributedMarkdown ?? ""),
		 .init(fontIcon: .circleTwo, text: LocalizableString.ClaimDevice.beforeBeginAssembleStation.localized.attributedMarkdown ?? "")]
	}

	override var secondSectionBullets: [ClaimDeviceBulletView.Bullet] {
		[.init(fontIcon: .circleThree, text: LocalizableString.ClaimDevice.beforeBeginPairStation.localized.attributedMarkdown ?? ""),
		 .init(fontIcon: .circleFour, text: LocalizableString.ClaimDevice.beforeBeginInstallStation.localized.attributedMarkdown ?? ""),
		 .init(fontIcon: .circleFive, text: LocalizableString.ClaimDevice.beforeBeginConfirmLocation.localized.attributedMarkdown ?? ""),
		 .init(fontIcon: .circleSix, text: LocalizableString.ClaimDevice.beforeBeginTakePhotos.localized.attributedMarkdown ?? ""),
		 .init(fontIcon: .circleSeven, text: LocalizableString.ClaimDevice.beforeBeginSetFrequency.localized.attributedMarkdown ?? ""),
		 .init(fontIcon: .circleEight, text: LocalizableString.ClaimDevice.beforeBeginAllDone.localized.attributedMarkdown ?? "")]
	}
}
