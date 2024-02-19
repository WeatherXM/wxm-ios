//
//  StationRewardsOverviewView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 31/10/23.
//

import SwiftUI
import Toolkit

struct StationRewardsOverviewView: View {

	let overview: StationRewardsCardOverview
	var showError: Bool = true
	var showErrorAction: Bool = true
	let buttonActions: RewardsOverviewButtonActions

    var body: some View {
        content
    }
}

private extension StationRewardsOverviewView {
	@ViewBuilder
	var content: some View {
		let lostAmountData = overview.lostAmountData
		VStack(spacing: CGFloat(.defaultSpacing)) {
			VStack(spacing: 0.0) {
				dateView
				HStack(spacing: CGFloat(.smallSpacing)) {
					Text("+ \(overview.actualReward.toWXMTokenPrecisionString) \(StringConstants.wxmCurrency)")
						.lineLimit(1)
						.font(.system(size: CGFloat(.titleFontSize), weight: .bold))
						.foregroundColor(Color(colorEnum: .darkestBlue))

					Spacer(minLength: 0.0)
					
					StationLostRewardsView(lostRewards: lostAmountData)
				}
			}

			if showError, lostAmountData.value > 0.0 {
				errorView(for: lostAmountData)
			}

			if let rewardScore = overview.rewardScore, let maxRewards = overview.maxRewards {
				PercentageGridLayoutView(firstColumnPercentage: 0.5) {
					Group {
						Button(action: buttonActions.rewardsScoreInfoAction) {
							let value = Double(rewardScore)/100.0
							rewardsScoreView(title: LocalizableString.StationDetails.rewardsScore.localized,
											 value: value.toPrecisionString(minDecimals: 2, precision: 2),
											 hexColor: getHexagonColor(validationScore: value))
						}
						Button(action: buttonActions.dailyMaxInfoAction) {
							rewardsScoreView(title: LocalizableString.StationDetails.rewardsMax.localized,
											 value: maxRewards.toWXMTokenPrecisionString,
											 hexColor: getHexagonColor(validationScore: maxRewards))
						}
					}
				}
			}

//			if let timelineEntries = overview.timelineEntries, !timelineEntries.isEmpty {
//				timelineView(for: timelineEntries, caption: overview.timelineCaption)
//			}
		}
	}

	@ViewBuilder
	var dateView: some View {
		HStack {
			Text(dateString)
			.font(.system(size: CGFloat(.normalFontSize)))
			.foregroundColor(Color(colorEnum: .darkGrey))
			Spacer()
		}
	}

	var dateString: String {
		if let fromDate = overview.fromDate, let toDate = overview.toDate {
			let from = fromDate.getFormattedDate(format: .monthLiteralDay,
												 relativeFormat: false,
												 timezone: .UTCTimezone,
												 showTimeZoneIndication: false).capitalizedSentence

			let to = toDate.getFormattedDate(format: .monthLiteralDay,
											 relativeFormat: false,
											 timezone: .UTCTimezone,
											 showTimeZoneIndication: true).capitalizedSentence
			return from + " - " + to
		}

		return overview.date?.getFormattedDate(format: .monthLiteralDayTime,
											   relativeFormat: false,
											   timezone: .UTCTimezone,
											   showTimeZoneIndication: true).capitalizedSentence ?? ""
	}

	@ViewBuilder
	func errorView(for lostAmount: StationRewardsLostAmountData) -> some View {
		StationRewardsErrorView(lostAmount: lostAmount.value,
								buttonTitle: overview.errorButtonTitle,
								showButton: showErrorAction,
								buttonTapAction: buttonActions.errorButtonAction)
			.WXMCardStyle(backgroundColor: Color(colorEnum: lostAmount.problemsViewBackground),
						  insideHorizontalPadding: CGFloat(.defaultSidePadding),
						  insideVerticalPadding: CGFloat(.smallToMediumSidePadding),
						  cornerRadius: CGFloat(.buttonCornerRadius))
	}

	@ViewBuilder
	func timelineView(for entries: [StationRewardsTimelineView.Value], caption: String?) -> some View {
		VStack(spacing: CGFloat(.smallToMediumSpacing)) {
			VStack(spacing: CGFloat(.minimumSpacing)) {
				StationRewardsTimelineView(values: entries)
					.frame(height: 70.0)

				if let axis = overview.timelineAxis {
					HStack {
						let count = axis.count
						ForEach(0..<count, id: \.self) { index in
							let val = axis[index]
							Text(val)
								.foregroundColor(Color(colorEnum: .text))
								.font(.system(size: CGFloat(.caption)))
							if index < count - 1 {
								Spacer()
							}
						}
					}
				}
			}

			if let caption {
				Button(action: buttonActions.timelineInfoAction) {
					HStack {
						Text(caption)
							.font(.system(size: CGFloat(.caption)))
							.foregroundColor(Color(colorEnum: .darkGrey))

						Text(FontIcon.infoCircle.rawValue)
							.font(.fontAwesome(font: .FAProLight, size: CGFloat(.caption)))
							.foregroundColor(Color(colorEnum: .text))
					}
				}
			}
		}
	}

	@ViewBuilder
	func rewardsScoreView(title: String, value: String, hexColor: ColorEnum) -> some View {
		HStack(alignment: .top, spacing: CGFloat(.minimumSpacing)) {
			Image(asset: .hexagonBigger)
				.renderingMode(.template)
				.foregroundColor(Color(colorEnum: hexColor))
				.frame(width: 24.0, height: 24.0)

			VStack(spacing: CGFloat(.minimumSpacing)) {
				HStack {
					Text(value)
						.font(.system(size: CGFloat(.caption)))
						.foregroundColor(Color(colorEnum: .text))

					Spacer()
				}

				HStack(spacing: CGFloat(.minimumSpacing)) {
					Text(title)
						.font(.system(size: CGFloat(.caption)))
						.foregroundColor(Color(colorEnum: .darkGrey))

					Text(FontIcon.infoCircle.rawValue)
						.font(.fontAwesome(font: .FAProLight, size: CGFloat(.caption)))
						.foregroundColor(Color(colorEnum: .text))

					Spacer()
				}
			}
		}
	}
}

#Preview {
	ZStack {
		StationRewardsOverviewView(overview: .mock(title: "Latest"),
							buttonActions: .init(rewardsScoreInfoAction: {},
												 dailyMaxInfoAction: {},
												 timelineInfoAction: {},
												 errorButtonAction: {}))
	}
}
