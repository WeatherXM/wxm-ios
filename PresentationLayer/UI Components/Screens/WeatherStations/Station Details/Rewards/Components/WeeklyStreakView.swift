//
//  WeeklyStreakView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 16/2/24.
//

import SwiftUI

struct WeeklyStreakView: View {
	let entries: [Int]

    var body: some View {
		VStack(spacing: CGFloat(.defaultSpacing)) {
			HStack {
				Text(LocalizableString.StationDetails.weeklyStreak.localized)
					.foregroundColor(Color(colorEnum: .text))
					.font(.system(size: CGFloat(.mediumFontSize), weight: .bold))
				Spacer()
			}

			StationRewardsTimelineView(values: entries)
				.frame(height: 80.0)
		}
		.WXMCardStyle()
    }
}

#Preview {
	let range = 0..<7
	let values = range.map { _ in Int.random(in: 0...100) }

	return WeeklyStreakView(entries: values)
		.wxmShadow()
		.padding()
}
