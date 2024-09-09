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

			BoostDetailsView(items: [.init(title: LocalizableString.RewardAnalytics.totalTokensEarnedSoFar.localized,
										   value: (details.currentRewards ?? 0).toWXMTokenPrecisionString + " " + StringConstants.wxmCurrency),
									 .init(title: LocalizableString.Boosts.totalTokensToBeRewarded.localized,
										   value: (details.totalRewards ?? 0).toWXMTokenPrecisionString + " " + StringConstants.wxmCurrency),
									 .init(title: LocalizableString.Boosts.boostPeriod.localized,
										   value: "\(details.boostStartDateString) -  \(details.boostStopDateString)")])
		}
    }
}
