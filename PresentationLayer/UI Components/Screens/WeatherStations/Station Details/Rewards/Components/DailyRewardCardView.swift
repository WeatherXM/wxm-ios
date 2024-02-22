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
	let buttonAction: VoidCallback?

    var body: some View {
		VStack(spacing: CGFloat(.defaultSpacing)) {
			titleView

			rewardsView

			if card.indication == nil, let buttonAction {
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
				Group {
					if let buttonAction {
						Button {
							buttonAction()
						} label: {
							Text(LocalizableString.StationDetails.viewRewardDetailsButtonTitle.localized)
						}
						.buttonStyle(WXMButtonStyle.transparent)
					} else {
						EmptyView()
					}
				}
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

					rewardsView(title: LocalizableString.StationDetails.boosts.localized,
								value: card.boostsReward,
								hexColor: .chartPrimary)

				Spacer()
			}
		}
	}

	@ViewBuilder
	func rewardsView(title: String, value: Double?, hexColor: ColorEnum) -> some View {
		HStack(alignment: .top, spacing: CGFloat(.minimumSpacing)) {
			Image(asset: .hexagonBigger)
				.renderingMode(.template)
				.foregroundColor(Color(colorEnum: hexColor))
				.frame(width: 24.0, height: 24.0)

			VStack(alignment: .leading, spacing: CGFloat(.minimumSpacing)) {
				Group {
					if let value {
						Text("\(value.toWXMTokenPrecisionString) \(StringConstants.wxmCurrency)").bold()
					} else {
						Text(LocalizableString.StationDetails.noActiveBoosts.localized)
					}
				}
				.font(.system(size: CGFloat(.caption)))
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
		let warningType: CardWarningType?

		var indication: (type: CardWarningType, text: String)? {
			guard let warningType else {
				return nil
			}

			switch warningType {
				case .error:
					return (warningType, LocalizableString.StationDetails.rewardErrorMessage.localized)
				case .warning:
					return (warningType, LocalizableString.StationDetails.rewardWarningMessage.localized)
				case .info:
					return (warningType, LocalizableString.StationDetails.rewardInfoMessage.localized)
			}
		}
	}
}

#Preview {
	DailyRewardCardView(card: .init(refDate: .now,
									totalRewards: 3.125312,
									baseReward: 2.4523532,
									baseRewardScore: 0.8,
									boostsReward: 1.4325423,
									warningType: .info)) {}
		.wxmShadow()
}

#Preview {
	DailyRewardCardView(card: .init(refDate: .now,
									totalRewards: 3.125312,
									baseReward: 2.4523532,
									baseRewardScore: 0.97,
									boostsReward: nil,
									warningType: nil)) {}
		.wxmShadow()
}

#Preview {
	DailyRewardCardView(card: .init(refDate: .now,
									totalRewards: 3.125312,
									baseReward: 2.4523532,
									baseRewardScore: 0.2,
									boostsReward: 1.4325423,
									warningType: .error)) {}
		.wxmShadow()
}
