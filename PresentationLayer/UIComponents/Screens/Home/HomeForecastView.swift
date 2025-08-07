//
//  HomeForecastView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 1/8/25.
//

import SwiftUI
import DomainLayer
import CoreLocation

struct HomeForecastView: View {
	let forecast: LocationForecast

    var body: some View {
		HStack(spacing: CGFloat(.mediumSpacing)) {
			LottieView(animationCase: forecast.icon.getAnimationString(),
					   loopMode: .loop)
			.frame(width: CGFloat(.weatherIconDefaultDimension),
				   height: CGFloat(.weatherIconDefaultDimension))

			VStack(spacing: CGFloat(.smallSpacing)) {
				HStack {
					Text(forecast.address)
						.fixedSize(horizontal: false, vertical: true)
						.multilineTextAlignment(.leading)
						.font(.system(size: CGFloat(.largeFontSize),
									  weight: .bold))
						.foregroundStyle(Color(colorEnum: .text))

					Spacer()
				}

				HStack {
					Text(forecast.icon.getWeatherDescription())
						.multilineTextAlignment(.leading)
						.font(.system(size: CGFloat(.caption)))
						.foregroundStyle(Color(colorEnum: .darkGrey))
						.fixedSize(horizontal: false, vertical: true)

					Spacer()
				}
			}

			Spacer()

			VStack(spacing: CGFloat(.smallSpacing)) {
				Text(forecast.temperature)
					.font(.system(size: CGFloat(.XXLTitleFontSize),
								  weight: .bold))
					.foregroundStyle(Color(colorEnum: .text))

				HStack(spacing: CGFloat(.minimumSpacing)) {
					Text(forecast.highTemperature)
						.font(.system(size: CGFloat(.mediumFontSize)))

					Color(colorEnum: .darkGrey)
						.frame(width: 1.0, height: 11.0)

					Text(forecast.lowTemperature)
						.font(.system(size: CGFloat(.normalFontSize)))
				}
				.foregroundStyle(Color(colorEnum: .darkGrey))

			}
		}.WXMCardStyle()
    }
}

#Preview {
	ZStack {
		Color(colorEnum: .bg)
		HomeForecastView(forecast: .init(address: "Address",
										 icon: "extreme-day-light-snow",
										 temperature: "29°C",
										 highTemperature: "35°C",
										 lowTemperature: "22°C"))
	}
}
