//
//  ClaimDeviceBeginViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 30/4/24.
//

import Foundation

class ClaimDeviceBeginViewModel: ObservableObject {
	let bullets: [ClaimDeviceBeginView.Bullet] = [.init(fontIcon: .circleOne, text: LocalizableString.ClaimDevice.connectD1BulletOne.localized.attributedMarkdown ?? ""),
												  .init(fontIcon: .circleTwo, text: LocalizableString.ClaimDevice.connectD1BulletTwo.localized.attributedMarkdown ?? ""),
												  .init(fontIcon: .circleThree, text: LocalizableString.ClaimDevice.connectD1BulletThree.localized.attributedMarkdown ?? ""),
												  .init(fontIcon: .circleFour, text: LocalizableString.ClaimDevice.connectD1BulletFour.localized.attributedMarkdown ?? "")]
}