//
//  MyStationsEmptyView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 11/2/25.
//

import SwiftUI
import Toolkit

struct MyStationsEmptyView: View {
	let buyButtonAction: VoidCallback
	let followButtonAction: VoidCallback

	var body: some View {
		VStack(spacing: CGFloat(.XLSpacing)) {
			VStack(spacing: CGFloat(.smallSpacing)) {
				Text(LocalizableString.MyStations.joinTheNetwork.localized)
					.foregroundStyle(Color(colorEnum: .text))
					.font(.system(size: CGFloat(.largeTitleFontSize), weight: .bold))

				Text(LocalizableString.MyStations.ownDeployEarnWXM.localized)
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
					HStack(spacing: CGFloat(.smallSpacing)) {
						Text(FontIcon.cart.rawValue)
							.font(.fontAwesome(font: .FAProSolid, size: CGFloat(.mediumFontSize)))

						Text(LocalizableString.MyStations.buyStation.localized)
					}
				}
				.buttonStyle(WXMButtonStyle.filled())

				Button {
					followButtonAction()
				} label: {
					Text(LocalizableString.MyStations.followAStationInExplorer.localized)
						.font(.system(size: CGFloat(.normalFontSize), weight: .bold))
						.foregroundStyle(Color(colorEnum: .wxmPrimary))
				}
			}
		}
		.padding(.horizontal, CGFloat(.defaultSidePadding))
	}
}

#Preview {
	MyStationsEmptyView(buyButtonAction: {}, followButtonAction: {})
}
