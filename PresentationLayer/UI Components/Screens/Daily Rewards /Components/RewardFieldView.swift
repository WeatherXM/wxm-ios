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
					Text(score.fontIcon.rawValue)
						.font(.fontAwesome(font: .FAProSolid, size: CGFloat(.smallTitleFontSize)))
						.foregroundColor(Color(colorEnum: score.color))

					Text(score.message)
						.font(.system(size: CGFloat(.caption)))
						.fixedSize(horizontal: false, vertical: true)

					Spacer()
				}

				if let scoreVal = score.score {
					ProgressView(value: scoreVal, total: 100)
						.progressViewStyle(ProgressBarStyle(withOffset: true,
															text: nil,
															bgColor: Color(colorEnum: .blueTint),
															progressColor: Color(colorEnum: score.color)))
						.frame(height: 22.0)
				}

			}
		}
		.WXMCardStyle()
		.indication(show: .constant(score.showIndication),
					borderColor: Color(colorEnum: score.color),
					bgColor: .clear, content: { EmptyView() })
    }
}

extension RewardFieldView {
	struct Score {
		let fontIcon: FontIcon
		let score: Float?
		let color: ColorEnum
		let message: String
		let showIndication: Bool
	}

}

#Preview {
	RewardFieldView(title: "Data Quality",
					score: .init(fontIcon: .hexagonExclamation,
								 score: nil,
								 color: .warning,
								 message: "Almost perfect! Got 98%.",
								 showIndication: true)) {}
		.wxmShadow()
		.padding()
}
