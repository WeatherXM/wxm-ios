//
//  StationRewardDetailsView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 6/9/24.
//

import SwiftUI
import DomainLayer

struct StationRewardDetailsView: View {
	let details: NetworkDeviceRewardsResponse.Details

    var body: some View {
		VStack(spacing: CGFloat(.mediumSpacing)) {
			if let code = details.code {
				HStack {
					Text(LocalizableString.RewardAnalytics.details(code.displayName).localized)
						.font(.system(size: CGFloat(.normalFontSize), weight: .medium))
						.foregroundStyle(Color(colorEnum: .text))

					Spacer()
				}

				let progress = details.completedPercentage ?? 0
				ProgressView(value: Float(progress), total: 100)
					.progressViewStyle(ProgressBarStyle(text: "\(progress)%",
														textColor: Color(colorEnum: .textDarkStable),
														bgColor: Color(colorEnum: code.primaryColor),
														progressColor: Color(colorEnum: code.fillColor)))
					.frame(height: 24)
			}

			BoostDetailsView(items: boostDetailsItems)
		}
    }
}

private extension StationRewardDetailsView {
	var boostDetailsItems: [BoostDetailsView.Item] {
		var items = [BoostDetailsView.Item]()
		if let currentRewards = details.currentRewards {
			items.append(.init(title: LocalizableString.RewardAnalytics.totalTokensEarnedSoFar.localized,
							   value: currentRewards.toWXMTokenPrecisionString + " " + StringConstants.wxmCurrency))
		}

		if let totalRewards = details.totalRewards {
			items.append(.init(title: LocalizableString.Boosts.totalTokensToBeRewarded.localized,
							   value: totalRewards.toWXMTokenPrecisionString + " " + StringConstants.wxmCurrency))
		}

		items.append(.init(title: LocalizableString.Boosts.boostPeriod.localized,
						   value: "\(details.boostStartDateString) - \(details.boostStopDateString)"))

		return items
	}
}
