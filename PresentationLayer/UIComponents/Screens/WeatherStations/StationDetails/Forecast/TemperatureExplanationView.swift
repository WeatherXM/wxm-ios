//
//  TemperatureExplanationView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 27/9/24.
//

import SwiftUI

struct TemperatureExplanationView: View {
    var body: some View {
		VStack(spacing: CGFloat(.defaultSpacing)) {
			HStack {
				Text(LocalizableString.Forecast.temperatureBarsTitle.localized)
					.font(.system(size: CGFloat(.smallTitleFontSize), weight: .bold))
					.foregroundStyle(Color(colorEnum: .darkestBlue))
				Spacer()
			}

			VStack(spacing: CGFloat(.smallSpacing)) {
				HStack {
					Text(LocalizableString.Forecast.weeklyRangeBar.localized)
						.font(.system(size: CGFloat(.mediumFontSize), weight: .bold))
						.foregroundStyle(Color(colorEnum: .text))
					Spacer()
				}

				HStack {
					Text(LocalizableString.Forecast.weeklyRangeDescription.localized)
						.font(.system(size: CGFloat(.caption)))
						.foregroundStyle(Color(colorEnum: .text))
					Spacer()
				}

			}

			VStack(spacing: CGFloat(.smallSpacing)) {
				HStack {
					Text(LocalizableString.Forecast.dailyRangeBar.localized)
						.font(.system(size: CGFloat(.mediumFontSize), weight: .bold))
						.foregroundStyle(Color(colorEnum: .text))
					Spacer()
				}

				HStack {
					Text(LocalizableString.Forecast.dailyRangeDescription.localized)
						.font(.system(size: CGFloat(.caption)))
						.foregroundStyle(Color(colorEnum: .text))
					Spacer()
				}

			}

			Image(asset: .temperatureBars)
				.resizable()
				.aspectRatio(contentMode: .fit)
				.wxmShadow()
		}
    }
}

#Preview {
    TemperatureExplanationView()
}
