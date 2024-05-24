//
//  ForecastFieldCardView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 16/4/24.
//

import SwiftUI

struct ForecastFieldCardView: View {
	let item: Item

    var body: some View {
		HStack(spacing: 0.0) {
			Image(asset: item.icon)
				.resizable()
				.renderingMode(.template)
				.foregroundColor(Color(colorEnum: .darkGrey))
				.frame(width: 35.0, height: 35.0)
				.rotationEffect(Angle(degrees: item.iconRotation))

			VStack(spacing: 0.0) {
				HStack {
					Text(item.title)
						.foregroundColor(Color(colorEnum: .darkGrey))
						.font(.system(size: CGFloat(.caption), weight: .bold))
						.multilineTextAlignment(.leading)
					Spacer()
				}

				HStack {
					Text(item.value)
					Spacer()
				}

			}

			Spacer()
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
		.WXMCardStyle()
    }
}

extension ForecastFieldCardView {
	struct Item {
		let icon: AssetEnum
		let iconRotation: Double
		let title: String
		let value: AttributedString
		var scrollToGraphType: ForecastChartType?
	}
}

#Preview {
	ForecastFieldCardView(item: .init(icon: .windDirIconSmall,
									  iconRotation: 45,
									  title: "Wind",
									  value: "6 high"))
	.wxmShadow()
}
