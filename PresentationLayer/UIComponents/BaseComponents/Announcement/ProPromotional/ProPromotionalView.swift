//
//  ProPromotionalView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 21/3/25.
//

import SwiftUI

struct ProPromotionalView: View {
	@StateObject var viewModel: ProPromotionalViewModel

	var body: some View {
		VStack(spacing: CGFloat(.defaultSpacing)) {
			LinearGradient(
				stops: [
					Gradient.Stop(color: Color(red: 0.16, green: 0.15, blue: 0.45), location: 0.00),
					Gradient.Stop(color: Color(red: 0.47, green: 0.23, blue: 0.69), location: 0.49),
					Gradient.Stop(color: Color(red: 0.3, green: 0.12, blue: 0.66), location: 1.00),
				],
				startPoint: UnitPoint(x: 0, y: 1),
				endPoint: UnitPoint(x: 1, y: 0)
			)
			.aspectRatio(1.7, contentMode: .fit)

			VStack(spacing: CGFloat(.defaultSpacing)) {
				HStack {
					Text(LocalizableString.Promotional.wxmPro.localized)
						.foregroundStyle(Color(colorEnum: .wxmPrimary))
						.font(.system(size: CGFloat(.smallTitleFontSize), weight: .bold))
					Spacer()
				}

				HStack {
					Text(LocalizableString.Promotional.proDescription.localized)
						.foregroundStyle(Color(colorEnum: .text))
						.font(.system(size: CGFloat(.normalFontSize)))
						.fixedSize(horizontal: false, vertical: true)
					Spacer()
				}

				bullets

				HStack {
					Text(LocalizableString.Promotional.choosePlan.localized)
						.foregroundStyle(Color(colorEnum: .text))
						.font(.system(size: CGFloat(.normalFontSize)))
						.fixedSize(horizontal: false, vertical: true)
					Spacer()
				}

				Button {
					viewModel.handleLearnMoreTapped()
				} label: {
					Text(LocalizableString.Promotional.learnMore.localized)
				}
				.buttonStyle(WXMButtonStyle(fillColor: .top, strokeColor: .noColor))


			}
			.padding(.horizontal, CGFloat(.defaultSidePadding))
			.padding(.bottom, CGFloat(.defaultSidePadding))
		}
		.background {
			Color(colorEnum: .layer1)
		}
		.ignoresSafeArea()
    }

	@ViewBuilder
	var bullets: some View {
		VStack(spacing: CGFloat(.smallToMediumSpacing)) {
			ForEach(viewModel.bulllets, id: \.self) { str in
				HStack(spacing: CGFloat(.smallToMediumSpacing)) {
					Text(FontIcon.check.rawValue)
						.font(.fontAwesome(font: .FAPro, size: CGFloat(.normalFontSize)))
						.foregroundStyle(Color(colorEnum: .wxmPrimary))

					Text(str)
						.foregroundStyle(Color(colorEnum: .text))
						.font(.system(size: CGFloat(.normalFontSize)))
					Spacer()
				}

			}
		}
	}
}

#Preview {
	VStack {
		ProPromotionalView(viewModel: ViewModelsFactory.getProPromotionalViewModel())
		Spacer()
	}
	.background(Color.red)
}
