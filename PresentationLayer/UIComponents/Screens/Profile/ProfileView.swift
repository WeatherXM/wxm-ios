//
//  ProfileView.swift
//  PresentationLayer
//
//  Created by Danae Kikue Dimou on 6/6/22.
//

import DomainLayer
import SwiftUI
import Toolkit

struct ProfileView: View {
    @StateObject var viewModel: ProfileViewModel
	@Binding var isTabBarShowing: Bool
	@Binding var tabBarItemsSize: CGSize

    var body: some View {
		NavigationContainerView(showBackButton: false) {
			ContentView(viewModel: viewModel, tabBarItemsSize: $tabBarItemsSize, isTabBarShowing: $isTabBarShowing)
		}
    }
}

private struct ContentView: View {
	@StateObject var viewModel: ProfileViewModel
	@Binding var tabBarItemsSize: CGSize
	@Binding var isTabBarShowing: Bool
	@EnvironmentObject var navigationObject: NavigationObject

	var body: some View {
		VStack(spacing: 0.0) {
			titleView
				.zIndex(1)

			TrackableScrollView(offsetObject: viewModel.scrollOffsetObject) { completion in
				viewModel.refresh(completion: completion)
			} content: {
				fieldsView
					.iPadMaxWidth()
					.padding(.bottom, tabBarItemsSize.height)
					.fail(show: $viewModel.isFailed, obj: viewModel.failObj)
			}
			.zIndex(0)
		}
		.spinningLoader(show: $viewModel.isLoading, hideContent: true)
		.bottomSheet(show: $viewModel.showInfo, fitContent: true) {
			bottomInfoView(info: viewModel.info)
		}
		.onAppear {
			navigationObject.title = LocalizableString.Profile.title.localized
			navigationObject.subtitle = viewModel.userInfoResponse.email ?? LocalizableString.noEmail.localized
		}
		.onChange(of: viewModel.userInfoResponse.email) { _ in
			navigationObject.subtitle = viewModel.userInfoResponse.email ?? LocalizableString.noEmail.localized
		}
		.onChange(of: viewModel.isTabBarVisible) { isVisible in
			withAnimation {
				isTabBarShowing = isVisible
			}
		}
	}

	var fieldsView: some View {
		VStack(spacing: CGFloat(.mediumSpacing)) {
			if let survey = viewModel.survey {
				Text(survey.title ?? "-")
			}
			ForEach(ProfileField.allCases, id: \.self) { field in
				switch field {
					case .rewards:
						rewardsView
					case .wallet:
						walletAddressView
					case .settings:
						settingsView
				}
			}
		}
		.padding(CGFloat(.defaultSidePadding))
	}

	var rewardsView: some View {
		HStack(spacing: CGFloat(.smallToMediumSpacing)) {
			Text(ProfileField.rewards.icon.rawValue)
				.font(.fontAwesome(font: .FAProSolid, size: CGFloat(.smallTitleFontSize)))
				.foregroundColor(Color(colorEnum: .text))

			VStack(alignment: .leading, spacing: CGFloat(.minimumSpacing)) {
				Text(ProfileField.rewards.title)
					.font(.system(size: CGFloat(.mediumFontSize), weight: .bold))
					.foregroundColor(Color(colorEnum: .wxmPrimary))

				Text(viewModel.allocatedRewards)
					.font(.system(size: CGFloat(.normalFontSize)))
					.foregroundColor(Color(colorEnum: .text))
			}

			Spacer(minLength: 0.0)

			if viewModel.isClaimAvailable {
				Button {
					viewModel.handleClaimButtonTap()
				} label: {
					Text(LocalizableString.Profile.claimButtonTitle.localized)
						.padding(.horizontal, CGFloat(.mediumToLargeSidePadding))
						.padding(.vertical, CGFloat(.smallToMediumSidePadding))
				}
				.buttonStyle(WXMButtonStyle(fillColor: .blueTint, strokeColor: .noColor, fixedSize: true))
			}
		}
		.WXMCardStyle()
		.indication(show: $viewModel.showRewardsIndication,
					borderColor: Color(colorEnum: viewModel.rewardsIndicationType.showBorder ? .wxmPrimary : .noColor),
					bgColor: Color(colorEnum: .blueTint)) {
			Group {
				switch viewModel.rewardsIndicationType {
					case .buyStation:
						buyStationView
					case .claimWeb:
						claimWebView
				}
			}
		}
					.wxmShadow()
	}

	@ViewBuilder
	var buyStationView: some View {
		CardWarningView(type: .info,
						showIcon: false,
						title: LocalizableString.Profile.noRewardsWarningTitle.localized,
						message: LocalizableString.Profile.noRewardsWarningDescription.localized,
						showContentFullWidth: true,
						closeAction: nil) {
			Button {
				viewModel.handleBuyStationTap()
			} label: {
				ZStack {
					HStack {
						Text(FontIcon.cart.rawValue)
							.font(.fontAwesome(font: .FAProSolid, size: CGFloat(.mediumFontSize)))

						Spacer()
					}

					Text(LocalizableString.Profile.noRewardsWarningButtonTitle.localized)
				}
				.padding(.horizontal, CGFloat(.defaultSidePadding))
			}
			.buttonStyle(WXMButtonStyle.filled())
		}
	}

	@ViewBuilder
	var claimWebView: some View {
		CardWarningView(type: .info,
						showIcon: false,
						title: nil,
						message: LocalizableString.Profile.claimFromWebDescription(viewModel.claimWebAppUrl).localized,
						closeAction: nil) { EmptyView() }
	}

	@ViewBuilder
	var walletAddressView: some View {
		Button {
			Router.shared.navigateTo(.wallet(ViewModelsFactory.getMyWalletViewModel()))
		} label: {
			HStack(spacing: CGFloat(.smallToMediumSpacing)) {
				Text(ProfileField.wallet.icon.rawValue)
					.font(.fontAwesome(font: .FAProSolid, size: CGFloat(.smallTitleFontSize)))
					.foregroundColor(Color(colorEnum: .text))

				VStack(alignment: .leading, spacing: CGFloat(.minimumSpacing)) {
					Text(ProfileField.wallet.title)
						.font(.system(size: CGFloat(.mediumFontSize), weight: .bold))
						.foregroundColor(Color(colorEnum: .wxmPrimary))

					if let walletAddress = viewModel.userInfoResponse.wallet?.address?.walletAddressMaskString, !walletAddress.isEmpty {
						Text(walletAddress)
							.font(.system(size: CGFloat(.normalFontSize), weight: .medium))
							.WXMCardStyle(backgroundColor: Color(colorEnum: .blueTint),
										  foregroundColor: Color(colorEnum: .text),
										  insideHorizontalPadding: CGFloat(.mediumSidePadding),
										  insideVerticalPadding: CGFloat(.smallSidePadding),
										  cornerRadius: CGFloat(.buttonCornerRadius))
					} else {
						Text(LocalizableString.Profile.noWalletAddressDescription.localized)
							.font(.system(size: CGFloat(.normalFontSize)))
							.foregroundColor(Color(colorEnum: .text))
					}
				}

				Spacer()
			}
			.WXMCardStyle()
			.indication(show: $viewModel.showMissingWalletError,
						borderColor: Color(colorEnum: .error),
						bgColor: Color(colorEnum: .errorTint)) {
				CardWarningView(type: .error,
								title: LocalizableString.Profile.noWalletAddressErrorTitle.localized,
								message: LocalizableString.Profile.noWalletAddressErrorDescription.localized,
								closeAction: nil,
								content: { EmptyView() })
			}
						.wxmShadow()
		}
		.buttonStyle(.plain)
	}

	var settingsView: some View {
		Button {
			Router.shared.navigateTo(.settings(ViewModelsFactory.getSettingsViewModel(userId: viewModel.userInfoResponse.id ?? "")))
		} label: {
			HStack(spacing: CGFloat(.smallToMediumSpacing)) {
				Text(ProfileField.settings.icon.rawValue)
					.font(.fontAwesome(font: .FAProSolid, size: CGFloat(.smallTitleFontSize)))
					.foregroundColor(Color(colorEnum: .text))

				VStack(alignment: .leading, spacing: CGFloat(.minimumSpacing)) {
					Text(ProfileField.settings.title)
						.font(.system(size: CGFloat(.mediumFontSize), weight: .bold))
						.foregroundColor(Color(colorEnum: .wxmPrimary))

					Text(LocalizableString.Profile.prefsSettingsDescription.localized)
						.font(.system(size: CGFloat(.normalFontSize)))
						.foregroundColor(Color(colorEnum: .text))
				}

				Spacer()
			}
			.WXMCardStyle()
			.wxmShadow()
		}
		.buttonStyle(.plain)
	}

	var titleView: some View {
		VStack {
			PercentageGridLayoutView(firstColumnPercentage: 0.5) {
				Group {
					tokenView(title: LocalizableString.Profile.totalEarned.localized,
							  value: viewModel.totalEarned) {
						viewModel.handleTotalEarnedInfoTap()
					}
							  .padding(.trailing, CGFloat(.smallToMediumSpacing)/2.0)
					
					tokenView(title: LocalizableString.Profile.totalClaimed.localized,
							  value: viewModel.totalClaimed) {
						viewModel.handleTotalClaimedInfoTap()
					}
							  .padding(.leading, CGFloat(.smallToMediumSpacing)/2.0)
				}
			}
			.padding(.horizontal, CGFloat(.defaultSidePadding))
			.padding(.bottom, CGFloat(.defaultSidePadding))
			.background {
				Color(colorEnum: .top)
			}
			.cornerRadius(CGFloat(.cardCornerRadius),
						  corners: [.bottomLeft, .bottomRight])
			.wxmShadow()
			.animation(.easeIn, value: viewModel.totalEarned)
		}
	}

	func tokenView(title: String, value: String, infoAction: @escaping VoidCallback) -> some View {
		VStack(spacing: CGFloat(.minimumSpacing)) {
			HStack {
				Text(title)
					.font(.system(size: CGFloat(.caption)))
					.foregroundColor(Color(colorEnum: .text))
				Spacer()

				Button(action: infoAction) {
					Text(FontIcon.infoCircle.rawValue)
						.font(.fontAwesome(font: .FAPro, size: CGFloat(.caption)))
						.foregroundColor(Color(colorEnum: .text))
				}

			}

			HStack {
				Text(value)
					.font(.system(size: CGFloat(.mediumFontSize), weight: .bold))
					.foregroundColor(Color(colorEnum: .text))

				Spacer()
			}
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
		.WXMCardStyle(backgroundColor: Color(colorEnum: .blueTint))
	}
}

struct Previews_ProfileView_Previews: PreviewProvider {
    static var previews: some View {
		ProfileView(viewModel: ViewModelsFactory.getProfileViewModel(), isTabBarShowing: .constant(true), tabBarItemsSize: .constant(.zero))
    }
}
