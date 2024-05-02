//
//  ClaimDeviceSerialNumberViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 2/5/24.
//

import Foundation

class ClaimDeviceSerialNumberViewModel: ObservableObject {
	var bullets: [ClaimDeviceBulletView.Bullet] {
		[.init(fontIcon: .circleOne, text: LocalizableString.ClaimDevice.prepareGatewayD1BulletOne.localized.attributedMarkdown ?? ""),
		 .init(fontIcon: .circleTwo, text: LocalizableString.ClaimDevice.prepareGatewayD1BulletTwo.localized.attributedMarkdown ?? "")]
	}

	var caption: AttributedString? {
		nil
	}

	func handleSNButtonTap() {

	}

	func handleQRCodeButtonTap() {
		
	}
}

class ClaimDeviceSerialNumberM5ViewModel: ClaimDeviceSerialNumberViewModel {
	override var bullets: [ClaimDeviceBulletView.Bullet] {
		[.init(fontIcon: .circleOne, text: LocalizableString.ClaimDevice.prepareGatewayM5BulletOne.localized.attributedMarkdown ?? ""),
		 .init(fontIcon: .circleTwo, text: LocalizableString.ClaimDevice.prepareGatewayM5BulletTwo.localized.attributedMarkdown ?? "")]
	}

	override var caption: AttributedString? {
		LocalizableString.ClaimDevice.prepareGatewayM5Caption.localized.attributedMarkdown
	}
}
