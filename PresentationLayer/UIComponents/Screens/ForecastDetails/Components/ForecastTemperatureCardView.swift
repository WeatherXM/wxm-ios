//
//  ForecastTemperatureCardView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 16/4/24.
//

import SwiftUI
import DomainLayer

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

					HStack(alignment: .bottom, spacing: CGFloat(.smallToMediumSpacing)) {
						Text(item.temperature)
							.foregroundColor(Color(colorEnum: .text))
							.font(.system(size: CGFloat(.XXLTitleFontSize)))
						Color(colorEnum: .text)
							.frame(width: 1.0, height: 26.0)
						Text(item.secondaryTemperature)
							.foregroundColor(Color(colorEnum: .text))
							.font(.system(size: CGFloat(.largeTitleFontSize)))

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
		let secondaryTemperature: String
		let scrollToGraphType: ForecastChartType?
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
		.frame(width: 100.0, height: 100.0)
	}
}

#Preview {
	ForecastTemperatureCardView(item: CurrentWeather.mockInstance.toForecastTemperatureItem(with: .current))
	.wxmShadow()
	.padding()
}
