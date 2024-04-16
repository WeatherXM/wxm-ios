//
//  ForecastTemperatureCardView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 16/4/24.
//

import SwiftUI

struct ForecastTemperatureCardView: View {
	let item: Item

    var body: some View {
		PercentageGridLayoutView(alignments: [.center, .leading], firstColumnPercentage: 0.3) {
			Group {
				weatherImage

				VStack(spacing: CGFloat(.smallToMediumSpacing)) {
					HStack {
						Text(item.dateString)
							.foregroundColor(Color(colorEnum: .darkestBlue))
							.font(.system(size: CGFloat(.mediumFontSize), weight: .bold))

						Spacer()
					}

					HStack(spacing: CGFloat(.smallSpacing)) {
						Text(item.temperature)
							.foregroundColor(Color(colorEnum: .text))
							.font(.system(size: CGFloat(.XXLTitleFontSize), weight: .bold))
						Color(colorEnum: .text)
							.frame(width: 1.0, height: 26.0)
						Text(item.feelsLike)
							.foregroundColor(Color(colorEnum: .text))
							.font(.system(size: CGFloat(.largeTitleFontSize), weight: .bold))

						Spacer()
					}
				}
			}
		}
		.WXMCardStyle()
    }
}

extension ForecastTemperatureCardView {
	struct Item {
		let weatherIcon: AnimationsEnums?
		let dateString: String
		let temperature: String
		let feelsLike: String
	}
}

private extension ForecastTemperatureCardView {
	@ViewBuilder
	var weatherImage: some View {
		Group {
			if let weatherIcon = item.weatherIcon {
				LottieView(animationCase: weatherIcon.animationString, loopMode: .loop)
			} else {
				LottieView(animationCase: "anim_not_available", loopMode: .loop)
			}
		}
	}
}

#Preview {
	ForecastTemperatureCardView(item: .init(weatherIcon: .clearNight,
											dateString: "Today, Tuesday, Apr 2",
											temperature: "16",
											feelsLike: "12"))
	.wxmShadow()
	.padding()
}
