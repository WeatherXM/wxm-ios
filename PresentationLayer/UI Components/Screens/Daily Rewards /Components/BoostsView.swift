//
//  BoostsView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 1/3/24.
//

import SwiftUI

struct BoostsView: View {
	let title: String
	let description: String
	let rewards: Double
	let imageUrl: String

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
		.background {
			AsyncImage(url: URL(string: imageUrl)!) { image in
				image
			} placeholder: {
				ProgressView()
			}
		}
		.WXMCardStyle()
		.contentShape(Rectangle())
    }
}

#Preview {
	BoostsView(title: "Beta reward",
			   description: "Rewarded for participating in our beta reward program.",
			   rewards: 2.453543,
			   imageUrl: "https://i0.wp.com/weatherxm.com/wp-content/uploads/2023/12/Home-header-image-1200-x-1200-px-2.png").wxmShadow()
		.padding()
}
