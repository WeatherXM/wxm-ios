//
//  BoostCardView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 6/3/24.
//

import SwiftUI
import NukeUI

struct BoostCardView: View {
	let boost: Boost

    var body: some View {
		VStack(spacing: CGFloat(.defaultSpacing)) {
			HStack {
				Text(boost.title)
					.font(.system(size: CGFloat(.titleFontSize), weight: .bold))
					.foregroundColor(Color(colorEnum: .white))
				Spacer()
			}

			VStack(spacing: CGFloat(.minimumSpacing)) {
				HStack {
					Text("+ \(boost.reward.toWXMTokenPrecisionString) \(StringConstants.wxmCurrency)")
						.font(.system(size: CGFloat(.XLTitleFontSize), weight: .bold))
						.foregroundColor(Color(colorEnum: .white))
					Spacer()
				}

				if let date = boost.date {
					HStack {
						Text(LocalizableString.Boosts.boostTokensEarned(date.getFormattedDate(format: .monthLiteralDayYear, timezone: .UTCTimezone, showTimeZoneIndication: true).capitalizedSentence).localized)
							.font(.system(size: CGFloat(.normalFontSize)))
							.foregroundColor(Color(colorEnum: .white))
						Spacer()
					}
				}
			}

			bottomView
		}
		.padding(CGFloat(.defaultSidePadding))
		.background {
			WXMRemoteImageView(imageUrl: boost.imageUrl)
		}
		.WXMCardStyle(insideHorizontalPadding: 0.0, 
					  insideVerticalPadding: 0.0)
		.contentShape(Rectangle())
    }
}

extension BoostCardView {
	struct Boost {
		let title: String
		let reward: Double
		let date: Date?
		let score: Int?
		let lostRewardString: String?
		let imageUrl: String?
	}
}

private extension BoostCardView {
	@ViewBuilder
	var bottomView: some View {
		if let score = boost.score,
		   let lostRewardString = boost.lostRewardString {
			VStack(spacing: CGFloat(.smallSpacing)) {
				HStack {
					Text(LocalizableString.Boosts.dailyBoostScore.localized)
						.font(.system(size: CGFloat(.normalFontSize)))
						.foregroundColor(Color(colorEnum: .white))
					
					Spacer()
					
					Text(LocalizableString.percentage(Float(score)).localized)
						.font(.system(size: CGFloat(.normalFontSize)))
						.foregroundColor(Color(colorEnum: .white))
				}

				Divider().overlay(Color(colorEnum: .lightLayer2))

				HStack {
					Text(lostRewardString)
						.font(.system(size: CGFloat(.normalFontSize)))
						.foregroundColor(Color(colorEnum: .white))
					Spacer()
				}
			}
		} else {
			EmptyView()
		}
	}
}

#Preview {
	BoostCardView(boost: .init(title: "Beta Reward",
							   reward: 0.24243534,
							   date: .now,
							   score: 90,
							   lostRewardString: LocalizableString.Boosts.lostTokens(1.4353452.toWXMTokenPrecisionString).localized,
							   imageUrl: "https://weatherxm.s3.eu-west-1.amazonaws.com/resources/public/BetaRewardsBoostImg.png"))
	.padding()
}
