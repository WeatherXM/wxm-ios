//
//  RewardAnalyticsViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 2/9/24.
//

import Foundation
import DomainLayer

class RewardAnalyticsViewModel: ObservableObject {
	
	let devices: [DeviceDetails]
	var totalEearnedText: String {
		let value = devices.reduce(0.0) { $0 + ($1.rewards?.totalRewards ?? 0.0) }
		return "\(value.toWXMTokenPrecisionString) \(StringConstants.wxmCurrency)"
	}
	var lastRunValueText: String {
		let value = devices.reduce(0.0) { $0 + ($1.rewards?.actualReward ?? 0.0) }
		return "\(value.toWXMTokenPrecisionString) \(StringConstants.wxmCurrency)"
	}

	@Published var state: RewardAnalyticsView.State = .noRewards
	private lazy var noStationsConfiguration: WXMEmptyView.Configuration = {
		WXMEmptyView.Configuration(imageFontIcon: (.faceSadCry, .FAProLight),
								   title: LocalizableString.RewardAnalytics.emptyStateTitle.localized,
								   description: LocalizableString.RewardAnalytics.emptyStateDescription.localized.attributedMarkdown,
								   buttonFontIcon: (.cart, .FAProSolid),
								   buttonTitle: LocalizableString.Profile.noRewardsWarningButtonTitle.localized) {
			HelperFunctions().openUrl(DisplayedLinks.shopLink.linkURL)
		}
	}()

	init(devices: [DeviceDetails]) {
		self.devices = devices
		updateState()
	}
}

private extension RewardAnalyticsViewModel {
	func updateState() {
		if devices.isEmpty {
			state = .empty(noStationsConfiguration)
		} else if devices.reduce(0, { $0 + ($1.rewards?.totalRewards ?? 0.0)}) == 0 {
			state = .noRewards
		} else {
			state = .content
		}
	}
}

extension RewardAnalyticsViewModel: HashableViewModel {
	func hash(into hasher: inout Hasher) {
		hasher.combine("\(devices.map { $0.id})")
	}
}
