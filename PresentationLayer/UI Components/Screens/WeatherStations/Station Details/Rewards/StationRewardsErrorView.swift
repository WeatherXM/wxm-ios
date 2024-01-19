//
//  StationRewardsErrorView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 2/11/23.
//

import SwiftUI
import Toolkit

struct StationRewardsErrorView: View {
	let lostAmount: Double
	let buttonTitle: String
	let showButton: Bool
	let buttonTapAction: VoidCallback

	private var description: String {
		guard lostAmount > 0.0 else {
			return LocalizableString.RewardDetails.zeroLostProblemsDescription.localized
		}

		return LocalizableString.StationDetails.rewardsErrorDescription(lostAmount.toWXMTokenPrecisionString).localized
	}

	var body: some View {
		VStack(spacing: CGFloat(.smallToMediumSpacing)) {
			HStack {
				Text(LocalizableString.StationDetails.rewardsErrorsTitle.localized)
					.font(.system(size: CGFloat(.normalFontSize), weight: .bold))
					.foregroundColor(Color(colorEnum: .text))
				Spacer()
			}

			HStack {
				Text(description.attributedMarkdown ?? "")
					.font(.system(size: CGFloat(.caption)))
					.foregroundColor(Color(colorEnum: .text))
					.fixedSize(horizontal: false, vertical: true)
				Spacer()
			}

			if showButton {
				Button(action: buttonTapAction) {
					Text(buttonTitle)
				}
				.buttonStyle(WXMButtonStyle.transparent)
			}
		}
    }
}

#Preview {
	StationRewardsErrorView(lostAmount: 349.2142, buttonTitle: LocalizableString.StationDetails.rewardsErrorButtonTitle.localized, showButton: true) {}
}
