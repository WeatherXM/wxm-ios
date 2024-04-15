//
//  StationForecastMiniCardView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 12/4/24.
//

import SwiftUI
import DomainLayer

struct StationForecastMiniCardView: View {
	let item: Item

	var body: some View {
		VStack(spacing: CGFloat(.smallSpacing)) {
			Text(item.time)
				.foregroundColor(Color(colorEnum: .darkestBlue))
				.font(.system(size: CGFloat(.caption)))

			weatherImage

			Text(item.temperature)
				.foregroundColor(Color(colorEnum: .darkestBlue))
				.font(.system(size: CGFloat(.normalFontSize), weight: .bold))
		}
		.WXMCardStyle()
    }
}

extension StationForecastMiniCardView {
	struct Item {
		let time: String
		let animationString: String?
		let temperature: String
	}
}

private extension StationForecastMiniCardView {
	@ViewBuilder
	var weatherImage: some View {
		Group {
			if let animationStr = item.animationString {
				LottieView(animationCase: animationStr, loopMode: .loop)
			} else {
				LottieView(animationCase: "anim_not_available", loopMode: .loop)
			}
		}
		.frame(width: 40.0, height: 40.0)
	}
}

#Preview {
	StationForecastMiniCardView(item: CurrentWeather.mockInstance.toMiniCardItem(with: .current))
		.wxmShadow()
}
