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
			LazyImage(url: URL(string: boost.imageUrl!)) { state in
				if let image = state.image {
					image.resizable()
				} else {
					ProgressView()
				}
			}
//			AsyncImage(url: URL(string: boost.imageUrl!)!) { image in
//				image
//					.resizable()
//			} placeholder: {
//				ProgressView()
//			}
		}
		.WXMCardStyle(insideHorizontalPadding: 0.0, insideVerticalPadding: 0.0)
		.contentShape(Rectangle())
    }
}

extension BoostCardView {
	struct Boost {
		let title: String
		let reward: Double
		let date: Date?
		let score: Int?
		let lostRewardString: String
		let imageUrl: String?
	}
}

private extension BoostCardView {
	@ViewBuilder
	var bottomView: some View {
		if let score = boost.score {
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
				
				Divider().overlay(Color(colorEnum: .top))
				
				HStack {
					Text(boost.lostRewardString)
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
							   score: nil,
							   lostRewardString: LocalizableString.Boosts.lostTokens(1.4353452.toWXMTokenPrecisionString).localized,
							   imageUrl: "https://s3-alpha-sig.figma.com/img/eb97/5518/24aa70629514355d092dfc646d9b51bd?Expires=1710720000&Key-Pair-Id=APKAQ4GOSFWCVNEHN3O4&Signature=OVc-UV-lBgXfX~Nl1VFoL-JijJx72Wld-L40tKQBLBo2afCyJijAJWkRicakQ~celi0ACIuP8W~N2Ixev1roqtO9JAl2IW0u55fOQdITuhDYq0pcqW-Nen7vzvATzti9A-c-pm6IDE37Md7gc0dYgnM55HhR1GAM4FlEIx4~RWOYmOI5rOgXQl6wN7YCB1gv3WI3JvmA1YgZKxLoei0Adny6PVGOlmQYXacN3WMcy6EfPFUO4rVvk~lrgQIOBJi8bSOnVX8RFHZ0RMW9lPljynCPKgbpuwUl0X6djRmdku-ntEnlCCsFp0LF0d~Y-qEK-edLpT96KdG4MM7TS64Qsg__"))
	.padding()
}
