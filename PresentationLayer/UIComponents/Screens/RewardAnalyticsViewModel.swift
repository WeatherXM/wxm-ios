//
//  RewardAnalyticsViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 2/9/24.
//

import Foundation
import DomainLayer

class RewardAnalyticsViewModel: ObservableObject {
	
	let devices: [NetworkDevicesResponse]
	
	@Published var state: RewardAnalyticsView.State
	
	init(devices: [NetworkDevicesResponse]) {
		self.devices = devices
		let obj = WXMEmptyView.Configuration(animationEnum: .emptyDevices,
											 title: LocalizableString.RewardAnalytics.emptyStateTitle.localized,
											 description: LocalizableString.RewardAnalytics.emptyStateDescription.localized.attributedMarkdown,
											 buttonFontIcon: .cart,
											 buttonTitle: LocalizableString.Profile.noRewardsWarningButtonTitle.localized) {}
		state = .empty(obj)
	}
}
