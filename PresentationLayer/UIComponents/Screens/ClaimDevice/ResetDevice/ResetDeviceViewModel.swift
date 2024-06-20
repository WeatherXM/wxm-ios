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

	var image: AssetEnum {
		.stationResetSchematic
	}

	var resetToggleText: String {
		LocalizableString.ClaimDevice.iVeResetMyDeviceButton.localized
	}
	
	var ctaButtonTitle: String {
		LocalizableString.ClaimDevice.pairStationViaBluetooth.localized
	}

	init(completion: @escaping VoidCallback) {
		self.completion = completion
	}

	func handleButtonTap() {
		completion()
	}
}

class ResetDevicePulseViewModel: ResetDeviceViewModel {
	override var bullets: [ClaimDeviceBulletView.Bullet] {
		[.init(fontIcon: .circleOne, text: LocalizableString.ClaimDevice.resetPulseBulletOne.localized.attributedMarkdown ?? ""),
		 .init(fontIcon: .circleTwo, text: LocalizableString.ClaimDevice.resetPulseBulletTwo.localized.attributedMarkdown ?? "")]
	}

	override var image: AssetEnum {
		.pulsePowerOn
	}

	override var resetToggleText: String {
		LocalizableString.ClaimDevice.resetPulseHasRebootedText.localized
	}

	override var ctaButtonTitle: String {
		LocalizableString.ClaimDevice.enterGatewayProceedButtonTitle.localized
	}
}
