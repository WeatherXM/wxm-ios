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
			HStack(spacing: 0.0) {
				Text(title)
					.font(.system(size: CGFloat(.normalFontSize), weight: .bold))

				Spacer(minLength: 0.0)

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
					if let fontIcon = score.fontIcon {
						Text(fontIcon.rawValue)
							.font(.fontAwesome(font: .FAProSolid, size: CGFloat(.smallTitleFontSize)))
							.foregroundColor(Color(colorEnum: score.color))
					}

					Text(score.message)
						.foregroundColor(Color(colorEnum: .darkGrey))
						.font(.system(size: CGFloat(.caption)))
						.fixedSize(horizontal: false, vertical: true)

					Spacer(minLength: 0.0)
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
		.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
		.WXMCardStyle()
		.indication(show: .constant(score.showIndication),
					borderColor: Color(colorEnum: score.color),
					bgColor: .clear, content: { EmptyView() })
    }
}

extension RewardFieldView {
	struct Score {
		let fontIcon: FontIcon?
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
