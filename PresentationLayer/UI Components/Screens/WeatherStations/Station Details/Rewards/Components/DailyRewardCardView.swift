//
//  DailyRewardCardView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 16/2/24.
//

import SwiftUI
import Toolkit

struct DailyRewardCardView: View {
	let card: Card
	let buttonAction: VoidCallback

    var body: some View {
		VStack(spacing: CGFloat(.defaultSpacing)) {
			titleView

			rewardsView

			if card.indication == nil {
				Button {
					buttonAction()
				} label: {
					Text(LocalizableString.StationDetails.viewRewardDetailsButtonTitle.localized)
				}
				.buttonStyle(WXMButtonStyle(fillColor: .layer1, strokeColor: .clear))
			}

		}
		.WXMCardStyle()
		.indication(show: Binding(get: { card.indication != nil }, set: { _ in }),
					borderColor: Color(colorEnum: card.indication?.type.iconColor ?? .clear),
					bgColor: Color(colorEnum: card.indication?.type.tintColor ?? .clear)) {
			CardWarningView(type: card.indication?.type ?? .info,
							showIcon: false,
							title: nil,
							message: card.indication?.text ?? "",
							showContentFullWidth: true,
							closeAction: nil) {
				Button {
					buttonAction()
				} label: {
					Text(LocalizableString.StationDetails.viewRewardDetailsButtonTitle.localized)
				}
				.buttonStyle(WXMButtonStyle.transparent)
			}
		}
    }
}

private extension DailyRewardCardView {
	var dateString: String {
		card.refDate?.getFormattedDate(format: .monthLiteralDayYear,
									   relativeFormat: false,
									   timezone: .UTCTimezone).capitalizedSentence ?? ""
	}

	@ViewBuilder
	var titleView: some View {
		VStack(spacing: CGFloat(.minimumSpacing)) {
			HStack {
				Text(LocalizableString.StationDetails.dailyRewardTitle.localized)
					.foregroundColor(Color(colorEnum: .text))
					.font(.system(size: CGFloat(.mediumFontSize), weight: .bold))
				Spacer()
			}

			HStack {
				Text(LocalizableString.StationDetails.dailyRewardEarnings(dateString).localized)
					.foregroundColor(Color(colorEnum: .darkGrey))
					.font(.system(size: CGFloat(.normalFontSize)))
				Spacer()
			}
		}
	}

	@ViewBuilder
	var rewardsView: some View {
		VStack(spacing: CGFloat(.smallSpacing)) {
			HStack {
				Text("+ \(card.totalRewards.toWXMTokenPrecisionString) \(StringConstants.wxmCurrency)")
					.lineLimit(1)
					.font(.system(size: CGFloat(.XLTitleFontSize), weight: .bold))
					.foregroundColor(Color(colorEnum: .darkestBlue))
				Spacer()
			}

			Divider()

			HStack(spacing: CGFloat(.mediumSpacing)) {
				rewardsView(title: LocalizableString.StationDetails.baseReward.localized,
							value: card.baseReward,
							hexColor: getHexagonColor(validationScore: card.baseRewardScore))

				if let boostsReward = card.boostsReward {
					rewardsView(title: LocalizableString.StationDetails.boosts.localized,
								value: boostsReward,
								hexColor: .primary)
				}

				Spacer()
			}
		}
	}

	@ViewBuilder
	func rewardsView(title: String, value: Double, hexColor: ColorEnum) -> some View {
		HStack(alignment: .top, spacing: CGFloat(.minimumSpacing)) {
			Image(asset: .hexagonBigger)
				.renderingMode(.template)
				.foregroundColor(Color(colorEnum: hexColor))
				.frame(width: 24.0, height: 24.0)

			VStack(alignment: .leading, spacing: CGFloat(.minimumSpacing)) {
				Text("\(value.toWXMTokenPrecisionString) \(StringConstants.wxmCurrency)")
					.font(.system(size: CGFloat(.caption), weight: .bold))
					.foregroundColor(Color(colorEnum: .darkGrey))

				Text(title)
					.font(.system(size: CGFloat(.caption)))
					.foregroundColor(Color(colorEnum: .darkGrey))

			}
		}
	}
}

extension DailyRewardCardView {
	struct Card: Hashable {
		let refDate: Date?
		let totalRewards: Double
		let baseReward: Double
		let baseRewardScore: Double
		let boostsReward: Double?

		var indication: (type: CardWarningType, text: String)? {
			switch baseRewardScore {
				case 0 ..< 0.7:
					return (.error, LocalizableString.StationDetails.rewardErrorMessage.localized)
				case 0.7 ..< 0.95:
					return (.warning, LocalizableString.StationDetails.rewardWarningMessage.localized)
				case 0.95 ..< 0.99:
					return (.info, LocalizableString.StationDetails.rewardInfoMessage.localized)
				default:
					return nil
			}
		}
	}
}

#warning("This is temporary")
extension StationRewardsCardOverview {
	var toDailyRewardCard: DailyRewardCardView.Card {
		DailyRewardCardView.Card(refDate: date,
								 totalRewards: actualReward,
								 baseReward: actualReward,
								 baseRewardScore: Double(rewardScore ?? 0) / 100.0,
								 boostsReward: 0.0)
	}
}

#Preview {
	DailyRewardCardView(card: .init(refDate: .now,
									totalRewards: 3.125312,
									baseReward: 2.4523532,
									baseRewardScore: 0.8,
									boostsReward: 1.4325423)) {}
		.wxmShadow()
}

#Preview {
	DailyRewardCardView(card: .init(refDate: .now,
									totalRewards: 3.125312,
									baseReward: 2.4523532,
									baseRewardScore: 0.97,
									boostsReward: 1.4325423)) {}
		.wxmShadow()
}

#Preview {
	DailyRewardCardView(card: .init(refDate: .now,
									totalRewards: 3.125312,
									baseReward: 2.4523532,
									baseRewardScore: 0.2,
									boostsReward: 1.4325423)) {}
		.wxmShadow()
}
