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
	
	@Published var state: RewardAnalyticsView.State = .noRewards
	private lazy var noStationsConfiguration: WXMEmptyView.Configuration = {
		WXMEmptyView.Configuration(imageFontIcon: (.faceSadCry, .FAProLight),
								   title: LocalizableString.RewardAnalytics.emptyStateTitle.localized,
								   description: LocalizableString.RewardAnalytics.emptyStateDescription.localized.attributedMarkdown,
								   buttonFontIcon: (.cart, .FAProSolid),
								   buttonTitle: LocalizableString.Profile.noRewardsWarningButtonTitle.localized) {

		}
	}()

	init(devices: [NetworkDevicesResponse]) {
		self.devices = devices
		updateState()
	}
}

private extension RewardAnalyticsViewModel {
	func updateState() {
		if devices.isEmpty {
			state = .empty(noStationsConfiguration)
		}
	}
}
