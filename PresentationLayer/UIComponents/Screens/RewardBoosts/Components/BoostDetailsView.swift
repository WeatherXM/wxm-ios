//
//  BoostDetailsView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 5/9/24.
//

import SwiftUI

struct BoostDetailsView: View {
	let items: [Item]

	var body: some View {
		VStack(spacing: CGFloat(.smallSpacing)) {
			ForEach(items, id: \.title) { item in
				detailsFieldView(title: item.title,
								 value: item.value)

				Divider()
					.overlay(Color(colorEnum: .layer2))
			}
		}
	}
}

extension BoostDetailsView {
	struct Item {
		let title: String
		let value: String
	}
}

private extension BoostDetailsView {
	@ViewBuilder
	func detailsFieldView(title: String, value: String) -> some View {
		HStack {
			Text(title)
				.font(.system(size: CGFloat(.normalFontSize)))
				.foregroundColor(Color(colorEnum: .text))
				.fixedSize(horizontal: false, vertical: true)

			Spacer()

			Text(value)
				.lineLimit(1)
				.font(.system(size: CGFloat(.caption), weight: .medium))
				.foregroundColor(Color(colorEnum: .text))
				.fixedSize()
		}
	}
}

#Preview {
	BoostDetailsView(items: [.init(title: LocalizableString.Boosts.rewardableStationHours.localized,
								   value: 24.435.toWXMTokenPrecisionString),
							 .init(title: LocalizableString.Boosts.dailyTokensToBeRewarded.localized, value: StringConstants.wxmCurrency)])
}
