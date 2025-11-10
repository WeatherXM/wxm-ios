//
//  ManageSubscriptionsView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 10/11/25.
//

import SwiftUI

struct ManageSubscriptionsView: View {
	@StateObject var viewModel: ManageSubscriptionsViewModel
	@EnvironmentObject var navigationObject: NavigationObject

	private let premiumFeaturesBullets: [(String, String)] = [(LocalizableString.Subscriptions.mosaicForecast.localized, LocalizableString.Subscriptions.mosaicForecastDescription.localized),
															 (LocalizableString.Subscriptions.hourlyForecast.localized, LocalizableString.Subscriptions.hourlyForecastDescription.localized)
	]
	
    var body: some View {
		ZStack {
			Color(colorEnum: .bg)
				.ignoresSafeArea()

			ScrollView {
				VStack(spacing: CGFloat(.mediumSpacing)) {
					HStack {
						Text(LocalizableString.Subscriptions.currentPlan.localized)
							.font(.system(size: CGFloat(.largeFontSize), weight: .bold))
							.foregroundStyle(Color(colorEnum: .text))

						Spacer()
					}

					currentPlan

					if !viewModel.isSubscribed {
						premiumFeatrues
					}
				}
				.padding(CGFloat(.mediumSidePadding))
			}.scrollIndicators(.hidden)
		}
		.onAppear {
			navigationObject.navigationBarColor = Color(colorEnum: .bg)
			navigationObject.title = LocalizableString.Subscriptions.manageSubscription.localized
		}
    }
}

extension ManageSubscriptionsView {
	@ViewBuilder
	var currentPlan: some View {
		VStack(spacing: CGFloat(.smallSpacing)) {
			HStack {
				let localizable: LocalizableString.Subscriptions = viewModel.isSubscribed ? .premium : .standard
				Text(localizable.localized)
					.font(.system(size: CGFloat(.largeFontSize), weight: .bold))
					.foregroundStyle(Color(colorEnum: .text))

				Spacer()

				Text(LocalizableString.Subscriptions.active.localized)
					.font(.system(size: CGFloat(.caption)))
					.foregroundStyle(Color(colorEnum: .bg))
					.padding(.horizontal, CGFloat(.smallToMediumSidePadding))
					.padding(.vertical, CGFloat(.smallSidePadding))
					.background {
						Capsule().fill(Color(colorEnum: .wxmPrimary))
					}
			}

			if !viewModel.isSubscribed {
				HStack {
					Text(LocalizableString.Subscriptions.standardDescription.localized)
						.font(.system(size: CGFloat(.normalFontSize)))
						.foregroundStyle(Color(colorEnum: .darkGrey))

					Spacer()
				}
			}
		}
		.WXMCardStyle()
	}

	@ViewBuilder
	var premiumFeatrues: some View {
		VStack(spacing: CGFloat(.mediumSpacing)) {
			HStack {
				Text(LocalizableString.Subscriptions.premiumFeatures.localized)
					.font(.system(size: CGFloat(.largeFontSize), weight: .bold))
					.foregroundStyle(Color(colorEnum: .text))

				Spacer()
			}

			VStack(spacing: CGFloat(.mediumSpacing)) {
				ForEach(premiumFeaturesBullets, id: \.0) { tuple in
					VStack(spacing: CGFloat(.minimumSpacing)) {
						HStack(spacing: CGFloat(.smallToMediumSpacing)) {
							Text(FontIcon.check.rawValue)
								.font(.fontAwesome(font: .FAProSolid,
												   size: CGFloat(.mediumFontSize)))
								.foregroundStyle(Color(colorEnum: .text))

							Text(tuple.0)
								.font(.system(size: CGFloat(.largeFontSize), weight: .bold))
								.foregroundStyle(Color(colorEnum: .text))

							Spacer()
						}

						HStack(spacing: CGFloat(.smallToMediumSpacing)) {
							Text(FontIcon.check.rawValue)
								.font(.fontAwesome(font: .FAProSolid,
												   size: CGFloat(.mediumFontSize)))
								.foregroundStyle(Color(colorEnum: .text))
								.opacity(0.0)

							Text(tuple.1)
								.font(.system(size: CGFloat(.normalFontSize)))
								.foregroundStyle(Color(colorEnum: .darkGrey))

							Spacer()
						}
					}
				}

				Button {
					viewModel.handleGetPremiumTap()
				} label: {
					Text(LocalizableString.Subscriptions.getPremium.localized)
				}
				.buttonStyle(WXMButtonStyle.filled())
			}
			.WXMCardStyle()
		}
	}
}

#Preview {
	NavigationContainerView {
		ManageSubscriptionsView(viewModel: ViewModelsFactory.getManageSubsriptionViewModel())
	}
}
