//
//  StationForecastMiniCardView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 12/4/24.
//

import SwiftUI
import DomainLayer
import Toolkit

struct StationForecastMiniCardView: View {
	static let defaultWidth: CGFloat = 84.0
	let item: Item
	let isSelected: Bool

	var body: some View {
		Button {
			item.action?()
		} label: {
			VStack(spacing: CGFloat(.smallSpacing)) {
				Text(item.time)
					.foregroundColor(Color(colorEnum: .darkestBlue))
					.font(.system(size: CGFloat(.caption)))
					.minimumScaleFactor(0.8)
					.lineLimit(1)

				weatherImage

				VStack(spacing: 0.0) {
					Text(item.temperature)
						.foregroundColor(Color(colorEnum: .darkestBlue))
						.font(.system(size: CGFloat(.normalFontSize), weight: .bold))
						.lineLimit(1)
						.fixedSize()

					if let secondaryTemperature = item.secondaryTemperature {
						Text(secondaryTemperature)
							.foregroundColor(Color(colorEnum: .darkestBlue))
							.font(.system(size: CGFloat(.caption)))
							.lineLimit(1)
					}
				}
			}
			.WXMCardStyle(backgroundColor: isSelected ? Color(colorEnum: .layer1) : Color(colorEnum: .top),
						  insideHorizontalPadding: CGFloat(.mediumSidePadding),
						  insideVerticalPadding: CGFloat(.mediumSidePadding))
		}
		.allowsHitTesting(item.action != nil)
		.indication(show: .constant(isSelected), borderColor: Color(colorEnum: .primary), bgColor: Color(colorEnum: .primary)) {
			EmptyView()
		}		
    }
}

extension StationForecastMiniCardView {
	struct Item {
		let time: String
		let animationString: String?
		let temperature: String
		var secondaryTemperature: String?
		var action: VoidCallback?
	}
}

private extension StationForecastMiniCardView {
	@ViewBuilder
	var weatherImage: some View {
		HStack {
			Spacer(minLength: 0.0)
			
			Group {
				if let animationStr = item.animationString {
					LottieView(animationCase: animationStr, loopMode: .loop)
				} else {
					LottieView(animationCase: "anim_not_available", loopMode: .loop)
				}
			}
			.frame(width: 40.0, height: 40.0)

			Spacer(minLength: 0.0)
		}
	}
}

#Preview {
	StationForecastMiniCardView(item: CurrentWeather.mockInstance.toMiniCardItem(with: .current), isSelected: true)
		.wxmShadow()
		.padding()
}
