//
//  BoostCardView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 6/3/24.
//

import SwiftUI

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
		.background {
			AsyncImage(url: URL(string: boost.imageUrl!)!) { image in
				image
			} placeholder: {
				ProgressView()
			}
		}
		.WXMCardStyle()
		.contentShape(Rectangle())
    }
}

extension BoostCardView {
	struct Boost {
		let title: String
		let reward: Double
		let date: Date?
		let score: Int
		let lostReward: Double
		let imageUrl: String?
	}
}

private extension BoostCardView {
	@ViewBuilder
	var bottomView: some View {
		VStack(spacing: CGFloat(.smallSpacing)) {
			HStack {
				Text(LocalizableString.Boosts.dailyBoostScore.localized)
					.font(.system(size: CGFloat(.normalFontSize)))
					.foregroundColor(Color(colorEnum: .white))
				Spacer()

				Text(LocalizableString.percentage(Float(boost.score)).localized)
					.font(.system(size: CGFloat(.normalFontSize)))
					.foregroundColor(Color(colorEnum: .white))
			}

			Divider().overlay(Color(colorEnum: .top))

			HStack {
				Text(LocalizableString.Boosts.lostTokens(boost.lostReward.toWXMTokenPrecisionString).localized)
					.font(.system(size: CGFloat(.normalFontSize)))
					.foregroundColor(Color(colorEnum: .white))
				Spacer()
			}
		}
	}
}

#Preview {
	BoostCardView(boost: .init(title: "Beta Reward",
							   reward: 0.24243534,
							   date: .now,
							   score: 72,
							   lostReward: 1.4353452,
							   imageUrl: "https://i0.wp.com/weatherxm.com/wp-content/uploads/2023/12/Home-header-image-1200-x-1200-px-2.png"))
}
