//
//  WeatherStationsEmptyView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 11/2/25.
//

import SwiftUI
import Toolkit

struct WeatherStationsEmptyView: View {
	let buyButtonAction: VoidCallback
	let followButtonAction: VoidCallback

	var body: some View {
		VStack(spacing: CGFloat(.XLSpacing)) {
			VStack(spacing: CGFloat(.smallSpacing)) {
				Text(LocalizableString.Home.joinTheNetwork.localized)
					.foregroundStyle(Color(colorEnum: .text))
					.font(.system(size: CGFloat(.largeTitleFontSize), weight: .bold))

				Text(LocalizableString.Home.ownDeployEarn.localized)
					.foregroundStyle(Color(colorEnum: .text))
					.font(.system(size: CGFloat(.normalFontSize)))
			}

			LottieView(animationCase: AnimationsEnums.weatherxmNetwork.animationString,
					   loopMode: .autoReverse)
			.aspectRatio(1.6, contentMode: .fit)
			.padding(.horizontal, CGFloat(.smallSidePadding))

			VStack(spacing: CGFloat(.mediumSpacing)) {
				Button {
					buyButtonAction()
				} label: {
					Text(LocalizableString.Home.buyStation.localized)
				}
				.buttonStyle(WXMButtonStyle.filled())

				Button {
					followButtonAction()
				} label: {
					Text(LocalizableString.Home.followAStationInExplorer.localized)
						.font(.system(size: CGFloat(.normalFontSize), weight: .bold))
						.foregroundStyle(Color(colorEnum: .wxmPrimary))
				}
			}
		}
		.padding(.horizontal, CGFloat(.defaultSidePadding))
	}
}

#Preview {
	WeatherStationsEmptyView(buyButtonAction: {}, followButtonAction: {})
}
