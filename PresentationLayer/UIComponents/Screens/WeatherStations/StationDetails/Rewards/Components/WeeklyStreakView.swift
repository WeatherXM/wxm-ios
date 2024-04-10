//
//  WeeklyStreakView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 16/2/24.
//

import SwiftUI
import Toolkit

struct WeeklyStreakView: View {
	let entries: [Entry]
	let buttonAction: VoidCallback

	private var startDay: String? {
		entries.first?.timestamp.getFormattedDate(format: .monthLiteralDay)
	}
	private var lastDay: String? {
		entries.last?.timestamp.getFormattedDate(format: .monthLiteralDay)
	}

    var body: some View {
		VStack(spacing: CGFloat(.defaultSpacing)) {
			VStack(spacing: 0.0) {
				HStack {
					Text(LocalizableString.StationDetails.weeklyStreak.localized)
						.foregroundColor(Color(colorEnum: .text))
						.font(.system(size: CGFloat(.mediumFontSize), weight: .bold))
					Spacer()
				}

				if let startDay, let lastDay {
					HStack {
						Text(LocalizableString.StationDetails.baseRewardRange(startDay.capitalized, lastDay.capitalized).localized)
							.foregroundColor(Color(colorEnum: .darkGrey))
							.font(.system(size: CGFloat(.normalFontSize)))
						Spacer()
					}
				}
			}

			VStack(spacing: CGFloat(.smallSpacing)) {
				StationRewardsTimelineView(values: entries.map { $0.toTimelineValue })
					.frame(height: 110.0)

				HStack {
					if let day = entries.first?.timestamp.getFormattedDate(format: .monthLiteralDay) {
						Text(day.capitalized)
							.foregroundColor(Color(colorEnum: .text))
							.font(.system(size: CGFloat(.caption)))
					}

					Spacer()

					if let day = entries.last?.timestamp.getFormattedDate(format: .monthLiteralDay) {
						Text(day.capitalized)
							.foregroundColor(Color(colorEnum: .text))
							.font(.system(size: CGFloat(.caption)))
					}
				}
			}

			Button {
				buttonAction()
			} label: {
				Text(LocalizableString.StationDetails.viewTimelineButtonTitle.localized)
			}
			.buttonStyle(WXMButtonStyle(fillColor: .layer1, strokeColor: .clear))
		}
		.WXMCardStyle()
    }
}

extension WeeklyStreakView {
	struct Entry: Hashable {
		let timestamp: Date
		let value: Int?
		let color: ColorEnum

		var toTimelineValue: StationRewardsTimelineView.Value {
			(timestamp.getWeekDay(.narrow), value, color)
		}
	}
}

#Preview {
	let range = 0..<7
	let values = range.map { _ in WeeklyStreakView.Entry(timestamp: .now,
														 value: Int.random(in: 0...100),
														 color: .blueTint) }

	return WeeklyStreakView(entries: values) {}
		.wxmShadow()
		.padding()
}
