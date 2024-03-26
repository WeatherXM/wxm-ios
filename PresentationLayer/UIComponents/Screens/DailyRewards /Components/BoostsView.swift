//
//  BoostsView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 1/3/24.
//

import SwiftUI
import NukeUI

struct BoostsView: View {
	let title: String
	let description: String
	let rewards: Double
	let imageUrl: String?

	var body: some View {
		VStack(spacing: CGFloat(.smallSpacing)) {
			HStack {
				Text(title)
					.font(.system(size: CGFloat(.normalFontSize), weight: .bold))
					.foregroundColor(Color(colorEnum: .white))
				Spacer()

				Text("+ \(rewards.toWXMTokenPrecisionString) \(StringConstants.wxmCurrency)")
					.font(.system(size: CGFloat(.caption), weight: .medium))
					.foregroundColor(Color(colorEnum: .white))
			}

			HStack {
				Text(description)
					.font(.system(size: CGFloat(.caption)))
					.foregroundColor(Color(colorEnum: .white))

				Spacer()
			}
		}
		.padding(CGFloat(.defaultSidePadding))
		.background {
			WXMRemoteImageView(imageUrl: imageUrl)
		}
		.WXMCardStyle(insideHorizontalPadding: 0.0, insideVerticalPadding: 0.0)
		.contentShape(Rectangle())
    }
}

#Preview {
	BoostsView(title: "Beta reward",
			   description: "Rewarded for participating in our beta reward program.",
			   rewards: 2.453543,
			   imageUrl: "https://s3-alpha-sig.figma.com/img/eb97/5518/24aa70629514355d092dfc646d9b51bd?Expires=1710720000&Key-Pair-Id=APKAQ4GOSFWCVNEHN3O4&Signature=OVc-UV-lBgXfX~Nl1VFoL-JijJx72Wld-L40tKQBLBo2afCyJijAJWkRicakQ~celi0ACIuP8W~N2Ixev1roqtO9JAl2IW0u55fOQdITuhDYq0pcqW-Nen7vzvATzti9A-c-pm6IDE37Md7gc0dYgnM55HhR1GAM4FlEIx4~RWOYmOI5rOgXQl6wN7YCB1gv3WI3JvmA1YgZKxLoei0Adny6PVGOlmQYXacN3WMcy6EfPFUO4rVvk~lrgQIOBJi8bSOnVX8RFHZ0RMW9lPljynCPKgbpuwUl0X6djRmdku-ntEnlCCsFp0LF0d~Y-qEK-edLpT96KdG4MM7TS64Qsg__").wxmShadow()
		.padding()
}
