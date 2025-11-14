//
//  SubscriptionCardView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 11/11/25.
//

import SwiftUI

struct SubscriptionCardView: View {
	let card: Card
	let isSelected: Bool

    var body: some View {
		HStack(spacing: CGFloat(.mediumSpacing)) {
			CircleRadius(isOptionActive: isSelected)

			VStack(spacing: CGFloat(.smallSpacing)) {
				HStack {
					Text(card.title)
						.font(.system(size: CGFloat(.caption)))
						.foregroundStyle(Color(colorEnum: .darkGrey))

					Spacer()
				}

				HStack {
					Text(card.price)
						.font(.system(size: CGFloat(.largeFontSize), weight: .bold))
						.foregroundStyle(Color(colorEnum: .text))

					Spacer()
				}

				if let trial = card.trial {
					HStack {
						Text(trial)
							.font(.system(size: CGFloat(.caption)))
							.foregroundStyle(Color(colorEnum: .success))
							.padding(.horizontal, CGFloat(.smallToMediumSidePadding))
							.padding(.vertical, CGFloat(.smallSidePadding))
							.background(Color(colorEnum: .successTint).cornerRadius(CGFloat(.smallCornerRadius)))

						Spacer()
					}
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
		.indication(show: .constant(isSelected),
					borderColor: Color(colorEnum: .wxmPrimary),
					bgColor: Color(colorEnum: .wxmPrimary)) {
			EmptyView()
		}
    }
}

extension SubscriptionCardView {
	struct Card: Identifiable, Equatable {
		var id: String {
			title
		}
		
		let title: String
		let price: String
		let description: String
		let trial: String?
	}
}

#Preview {
	SubscriptionCardView(card: .init(title: "MONTHLY",
									 price: "$3.99/month",
									 description: "then $3.99 per month. Cancel anytime.",
									 trial: LocalizableString.Subscriptions.freeTrial(1, "Week").localized),
						 isSelected: true)
}
