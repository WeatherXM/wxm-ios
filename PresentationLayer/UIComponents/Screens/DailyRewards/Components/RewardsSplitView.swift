//
//  RewardsSplitView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 14/8/24.
//

import SwiftUI
import DomainLayer
import Toolkit

struct RewardsSplitView: View {
	let items: [Item]
	let buttonAction: VoidCallback

    var body: some View {
		ZStack {
			Color(colorEnum: .top)
				.ignoresSafeArea()

			VStack {
				VStack(spacing: CGFloat(.mediumSpacing)) {
					titleView

					walletsList
				}
				
				Button(action: buttonAction) {
					Text(LocalizableString.done.localized)
				}
				.buttonStyle(WXMButtonStyle.transparent(fillColor: .layer1))

			}
			.padding(CGFloat(.defaultSidePadding))
			.padding(.top, CGFloat(.defaultSidePadding))
		}
    }
}

extension RewardsSplitView {
	
	struct WalletsListView: View {
		let items: [Item]

		var body: some View {
			VStack(spacing: CGFloat(.smallToMediumSpacing)) {
				ForEach(items, id: \.address) { item in
					VStack(spacing: CGFloat(.smallSpacing)) {
						HStack {
							let weight: Font.Weight = item.isUserWallet ? .bold : .regular

							Text(addressString(item: item))
								.font(.system(size: CGFloat(.mediumFontSize), weight: weight))
								.foregroundStyle(Color(colorEnum: .darkGrey))
								.fixedSize(horizontal: false, vertical: true)

							Spacer()

							Text(item.valueString)
								.font(.system(size: CGFloat(.mediumFontSize),
											  weight: weight))
								.foregroundStyle(Color(colorEnum: .darkGrey))
								.fixedSize(horizontal: false, vertical: true)
						}

						WXMDivider()
					}
				}
			}
		}

		func addressString(item: Item) -> String {
			var address = item.address.walletAddressMaskString
			if item.isUserWallet {
				address += " (\(LocalizableString.you.localized))"
			}

			return address
		}
	}
}

extension RewardsSplitView {
	struct Item {
		let address: String
		let reward: Double?
		let stake: Double
		let isUserWallet: Bool
	}
}

private extension RewardsSplitView.Item {
	var valueString: String {
		var str = "(\(LocalizableString.percentage(Float(stake)).localized))"
		if let reward {
			str = "\(reward.toWXMTokenPrecisionString) \(StringConstants.wxmCurrency) " + str
		}

		return str
	}
}

private extension RewardsSplitView {
	@ViewBuilder
	var titleView: some View {
		VStack(spacing: CGFloat(.smallSpacing)) {
			HStack {
				Text(LocalizableString.RewardDetails.rewardSplit.localized)
					.font(.system(size: CGFloat(.mediumFontSize), weight: .bold))
					.foregroundStyle(Color(colorEnum: .text))

				Spacer()
			}

			HStack {
				Text(LocalizableString.RewardDetails.rewardSplitDescription(items.count).localized)
					.font(.system(size: CGFloat(.normalFontSize)))
					.foregroundStyle(Color(colorEnum: .text))

				Spacer()
			}

		}
	}

	@ViewBuilder
	var walletsList: some View {
		ScrollView(showsIndicators: false) {
			WalletsListView(items: items)
		}
	}
}

#Preview {
	RewardsSplitView(items: [RewardSplit(stake: 60,
										 wallet: "0xc4E253863371fdeD8e414731DB951F4C17Bc645e",
										 reward: 1.2).toSplitViewItem(isUserWallet: true)]) {}
		.padding()
}
