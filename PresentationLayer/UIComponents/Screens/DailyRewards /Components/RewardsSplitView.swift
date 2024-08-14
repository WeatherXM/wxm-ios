//
//  RewardsSplitView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 14/8/24.
//

import SwiftUI
import DomainLayer

struct RewardsSplitView: View {
	let rewardSplits: [RewardSplit]

    var body: some View {
		ZStack {
			Color(colorEnum: .top)
				.ignoresSafeArea()

			VStack(spacing: CGFloat(.mediumSpacing)) {
				titleView

				walletsList
			}
		}
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
				Text(LocalizableString.RewardDetails.rewardSplitDescription(rewardSplits.count).localized)
					.font(.system(size: CGFloat(.normalFontSize)))
					.foregroundStyle(Color(colorEnum: .text))

				Spacer()
			}

		}
	}

	@ViewBuilder
	var walletsList: some View {
		ScrollView(showsIndicators: false) {
			VStack(spacing: CGFloat(.smallToMediumSpacing)) {
				ForEach(rewardSplits, id: \.wallet) { split in
					VStack(spacing: CGFloat(.smallSpacing)) {
						HStack {
							Text(split.wallet?.walletAddressMaskString ?? "")
								.font(.system(size: CGFloat(.mediumFontSize)))
								.foregroundStyle(Color(colorEnum: .darkGrey))

							Spacer()

							HStack(spacing: CGFloat(.smallSpacing)) {
								Text("\(split.reward?.toWXMTokenPrecisionString ?? "") \(StringConstants.wxmCurrency)")

								Text("(\(LocalizableString.percentage(Float(split.stake ?? 0)).localized))")
							}
							.font(.system(size: CGFloat(.mediumFontSize)))
							.foregroundStyle(Color(colorEnum: .darkGrey))
						}

						WXMDivider()
					}
				}
			}
		}
	}
}

#Preview {
	RewardsSplitView(rewardSplits: [.init(stake: 60,
										  wallet: "0xc4E253863371fdeD8e414731DB951F4C17Bc645e",
										  reward: 1.2)])
	.padding()
}
