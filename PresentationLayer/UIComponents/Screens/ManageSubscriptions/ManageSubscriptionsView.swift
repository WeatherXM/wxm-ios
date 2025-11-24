//
//  ManageSubscriptionsView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 10/11/25.
//

import SwiftUI
import Toolkit

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

			VStack {
				ScrollView {
					VStack(spacing: CGFloat(.mediumSpacing)) {
						HStack {
							Text(LocalizableString.Subscriptions.currentPlan.localized)
								.font(.system(size: CGFloat(.largeFontSize), weight: .bold))
								.foregroundStyle(Color(colorEnum: .text))

							Spacer()
						}

						currentPlan

						switch viewModel.state {
							case .standard, .canceled:
								premiumFeatruesCard
							case .subscribed:
								EmptyView()
						}

					}
					.padding(CGFloat(.mediumSidePadding))
					.iPadMaxWidth()
				}
				.scrollIndicators(.hidden)
				.refreshable {
					await viewModel.refresh()
				}
			}
			.task {
				await viewModel.refresh()
			}
			.spinningLoader(show: $viewModel.isLoading)
		}
		.onAppear {
			navigationObject.navigationBarColor = Color(colorEnum: .bg)
			navigationObject.title = LocalizableString.Subscriptions.manageSubscription.localized

			WXMAnalytics.shared.trackScreen(.manageSubscription)
		}
    }
}

extension ManageSubscriptionsView {
	@ViewBuilder
	var currentPlan: some View {
		switch viewModel.state {
			case .standard:
				planCardView(title: LocalizableString.Subscriptions.standard.localized,
							 subtitle: nil,
							 description: LocalizableString.Subscriptions.standardDescription.localized,
							 isCanceled: false) {
					EmptyView()
				}
			case .subscribed:
				planCardView(title: LocalizableString.Subscriptions.premiumForecast.localized,
							 subtitle: nil,
							 description: nil,
							 isCanceled: false) {
					VStack(spacing: CGFloat(.defaultSpacing)) {
						premiumFeatures

						Button {
							viewModel.handleManageSubscriptionTap()
						} label: {
							Text(LocalizableString.Subscriptions.manageSubscription.localized)
						}
						.buttonStyle(WXMButtonStyle(fillColor: .layer1, strokeColor: .layer1))
					}
				}
			case .canceled:
				ForEach(viewModel.products, id: \.identifier) { product in
					planCardView(title: product.name,
								 subtitle: nil,
								 description: product.expirationDateString,
								 isCanceled: product.isCanceled) {
							Button {
								viewModel.handleManageSubscriptionTap()
							} label: {
								Text(LocalizableString.Subscriptions.manageSubscription.localized)
							}
							.buttonStyle(WXMButtonStyle(fillColor: .layer1, strokeColor: .layer1))
					}
				}
		}
	}

	@ViewBuilder
	var premiumFeatruesCard: some View {
		VStack(spacing: CGFloat(.mediumSpacing)) {
			HStack {
				Text(LocalizableString.Subscriptions.premiumFeatures.localized)
					.font(.system(size: CGFloat(.largeFontSize), weight: .bold))
					.foregroundStyle(Color(colorEnum: .text))

				Spacer()
			}

			VStack(spacing: CGFloat(.mediumSpacing)) {

				premiumFeatures

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

	@ViewBuilder
	var premiumFeatures: some View {
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
		}
	}

	@ViewBuilder
	func planCardView(title: String,
					  subtitle: String?,
					  description: String?,
					  isCanceled: Bool,
					  bottomView: () -> some View) -> some View {
		VStack(spacing: CGFloat(.defaultSpacing)) {
			VStack(spacing: CGFloat(.smallSpacing)) {
				HStack {
					Text(title)
						.font(.system(size: CGFloat(.largeFontSize), weight: .bold))
						.foregroundStyle(Color(colorEnum: .text))
					
					Spacer()
					
					let pillText: LocalizableString.Subscriptions = isCanceled ? .canceled : .active
					Text(pillText.localized)
						.font(.system(size: CGFloat(.caption)))
						.foregroundStyle(Color(colorEnum: isCanceled ? .textWhite : .top))
						.padding(.horizontal, CGFloat(.smallToMediumSidePadding))
						.padding(.vertical, CGFloat(.smallSidePadding))
						.background {
							Capsule().fill(Color(colorEnum: isCanceled ? .error : .wxmPrimary))
						}
				}
				
				if let subtitle {
					HStack {
						Text(subtitle)
							.font(.system(size: CGFloat(.largeFontSize), weight: .bold))
							.foregroundStyle(Color(colorEnum: .text))
						
						Spacer()
					}
				}
				
				if let description {
					HStack {
						Text(description)
							.font(.system(size: CGFloat(.normalFontSize)))
							.foregroundStyle(Color(colorEnum: .darkGrey))
						
						Spacer()
					}
				}
			}

			bottomView()
		}
		.WXMCardStyle(backgroundColor: isCanceled ? .errorTint : .top)
	}
}

extension ManageSubscriptionsView {
	enum State {
		case standard
		case subscribed
		case canceled
	}
}

#Preview {
	NavigationContainerView {
		ManageSubscriptionsView(viewModel: ViewModelsFactory.getManageSubsriptionViewModel())
	}
}
