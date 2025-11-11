//
//  SubscriptionCardView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 11/11/25.
//

import SwiftUI

struct SubscriptionCardView: View {
	let card: Card

    var body: some View {
		HStack(spacing: CGFloat(.mediumSpacing)) {
			CircleRadius(isOptionActive: card.isSelected)

			VStack(spacing: CGFloat(.smallSpacing)) {
				HStack {
					Text(card.title)
						.font(.system(size: CGFloat(.caption)))
						.foregroundStyle(Color(colorEnum: .darkGrey))

					Spacer()
				}

				HStack {
					Text(card.price)
						.font(.system(size: CGFloat(.largeFontSize)))
						.foregroundStyle(Color(colorEnum: .text))

					Spacer()
				}

				HStack {
					Text(card.description)
						.font(.system(size: CGFloat(.normalFontSize)))
						.foregroundStyle(Color(colorEnum: .darkGrey))

					Spacer()
				}
			}
		}
		.WXMCardStyle()
    }
}

extension SubscriptionCardView {
	struct Card {
		let title: String
		let price: String
		let description: String
		var isSelected: Bool = false

		mutating func setSelected(_ isSelected: Bool) {
			self.isSelected = isSelected
		}
	}
}

#Preview {
	SubscriptionCardView(card: .init(title: "MONTHLY",
									 price: "$3.99/month",
									 description: "then $3.99 per month. Cancel anytime.",
									 isSelected: true))
}
