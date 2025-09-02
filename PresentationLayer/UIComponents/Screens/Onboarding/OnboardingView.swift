//
//  OnboardingView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 2/9/25.
//

import SwiftUI

struct OnboardingView: View {
    var body: some View {
		VStack(spacing: CGFloat(.smallSpacing)) {
			Image(asset: .weatherXMLogoText)
			Text(LocalizableString.Onboarding.title.localized)
				.foregroundStyle(Color(colorEnum: .textDarkStable))
				.font(.system(size: CGFloat(.smallTitleFontSize)))

			GeometryReader { _ in
				ScrollView(.horizontal) {
					Text(verbatim: "TEST")
				}
			}

			VStack(spacing: CGFloat(.defaultSpacing)) {
				Button {

				} label: {
					Text(LocalizableString.Onboarding.signUpButtonTitle.localized)
						.foregroundStyle(Color(colorEnum: .darkBg))
						.font(.system(size: CGFloat(.mediumFontSize),
									  weight: .bold))
				}
				.buttonStyle(WXMButtonStyle(fillColor: .textWhite,
											strokeColor: .textWhite,
											cornerRadius: 25.0))

				Button {

				} label: {
					Text(LocalizableString.Onboarding.exploreTheAppButtonTitle.localized)
						.foregroundStyle(Color(colorEnum: .textWhite))
						.font(.system(size: CGFloat(.mediumFontSize),
									  weight: .bold))
				}
				.buttonStyle(.plain)
			}
		}
		.padding(CGFloat(.largeSidePadding))
    }
}

#Preview {
	ZStack {
		Color(colorEnum: .bg)
			.ignoresSafeArea()
		OnboardingView()
	}
}
