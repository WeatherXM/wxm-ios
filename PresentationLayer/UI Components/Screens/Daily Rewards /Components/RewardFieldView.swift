//
//  RewardFieldView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 27/2/24.
//

import SwiftUI
import Toolkit

struct RewardFieldView: View {
	let title: String
	let score: Score
	let infoAction: VoidCallback

    var body: some View {
		VStack(spacing: CGFloat(.smallSpacing)) {
			HStack {
				Text(title)
					.font(.system(size: CGFloat(.mediumFontSize), weight: .bold))

				Spacer()

				Button{
					infoAction()
				} label: {
					Text(FontIcon.infoCircle.rawValue)
						.font(.fontAwesome(font: .FAPro, size: CGFloat(.mediumFontSize)))
				}
			}
			.foregroundColor(Color(colorEnum: .text))

			VStack(spacing: CGFloat(.mediumSpacing)) {
				HStack(spacing: CGFloat(.smallSpacing)) {
					Text(FontIcon.hexagonCheck.rawValue)
						.font(.fontAwesome(font: .FAProSolid, size: CGFloat(.smallTitleFontSize)))
						.foregroundColor(Color(colorEnum: score.color))

					Text(score.message)
						.font(.system(size: CGFloat(.caption)))

					Spacer()
				}

				ProgressView(value: score.score, total: 100)
					.progressViewStyle(ProgressBarStyle(text: nil, bgColor: Color(colorEnum: .blueTint), progressColor: Color(colorEnum: score.color)))
					.frame(height: 22.0)

			}
		}
		.WXMCardStyle()
    }
}

extension RewardFieldView {
	struct Score {
		let score: Float
		let color: ColorEnum
		let message: String
	}

}

#Preview {
	RewardFieldView(title: "Data Quality",
					score: .init(score: 75.0, color: .warning, message: "Almost perfect! Got 98%.")) {}
		.wxmShadow()
		.padding()
}
