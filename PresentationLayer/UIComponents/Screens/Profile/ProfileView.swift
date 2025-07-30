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

    var body: some View {
		NavigationContainerView(showBackButton: false) {
			ContentView(viewModel: viewModel)
		}
    }
}

private struct ContentView: View {
	@StateObject var viewModel: ProfileViewModel
	@EnvironmentObject var navigationObject: NavigationObject

	var body: some View {
		VStack(spacing: 0.0) {
			titleView
				.zIndex(1)

			TrackableScroller(offsetObject: viewModel.scrollOffsetObject) { completion in
				viewModel.refresh(completion: completion)
			} content: {
				fieldsView
					.iPadMaxWidth()
					.fail(show: $viewModel.isFailed, obj: viewModel.failObj)
			}
			.zIndex(0)

			if !MainScreenViewModel.shared.isUserLoggedIn {
				signInContainer
			}
		}
		.spinningLoader(show: $viewModel.isLoading, hideContent: true)
		.bottomSheet(show: $viewModel.showInfo) {
			bottomInfoView(info: viewModel.info)
		}
		.onAppear {
			navigationObject.title = LocalizableString.Profile.title.localized

			let email = viewModel.userInfoResponse.email ?? LocalizableString.noEmail.localized
			navigationObject.subtitle = viewModel.isLoggedIn ? email : LocalizableString.Profile.loginToSee.localized
		}
		.onChange(of: viewModel.userInfoResponse.email) { _ in
			navigationObject.subtitle = viewModel.userInfoResponse.email ?? LocalizableString.noEmail.localized
		}
	}

	var fieldsView: some View {
		VStack(spacing: CGFloat(.mediumSpacing)) {
			if let surveyConf = viewModel.surveyConfiguration {
				AnnouncementCardView(configuration: surveyConf)
			}

			ForEach(viewModel.profileFields, id: \.self) { field in
				switch field {
					case .rewards:
						rewardsView
					case .wallet:
						walletAddressView
					case .settings:
						settingsView
				}
			}

			ProBannerView(description: LocalizableString.Promotional.takeYourWeatherInsights.localized,
						  analyticsSource: .localProfile)
		}
		.padding(CGFloat(.defaultSidePadding))
		.animation(.easeIn, value: viewModel.surveyConfiguration != nil)
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
		CardWarningView(configuration: .init(type: .info,
											 showIcon: false,
											 title: LocalizableString.Profile.noRewardsWarningTitle.localized,
											 message: LocalizableString.Profile.noRewardsWarningDescription.localized,
											 closeAction: nil),
						showContentFullWidth: true) {
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
		CardWarningView(configuration: .init(type: .info,
											 showIcon: false,
											 title: nil,
											 message: LocalizableString.Profile.claimFromWebDescription(viewModel.claimWebAppUrl).localized,
											 closeAction: nil)) { EmptyView() }
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
				CardWarningView(configuration: .init(type: .error,
													 title: LocalizableString.Profile.noWalletAddressErrorTitle.localized,
													 message: LocalizableString.Profile.noWalletAddressErrorDescription.localized,
													 closeAction: nil),
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

	@ViewBuilder
	var titleView: some View {
		if viewModel.isLoggedIn {
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
				.wxmShadow()
				.animation(.easeIn, value: viewModel.totalEarned)
			}
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

	@ViewBuilder
	var signInContainer: some View {
		VStack(spacing: CGFloat(.defaultSpacing)) {
			signInButton
			signUpTextButton
		}
		.WXMCardStyle()
		.iPadMaxWidth()
		.padding(CGFloat(.defaultSidePadding))
	}

	@ViewBuilder
	var signInButton: some View {
		Button {
			Router.shared.navigateTo(.signIn(ViewModelsFactory.getSignInViewModel()))
		} label: {
			Text(LocalizableString.signIn.localized)
		}
		.buttonStyle(WXMButtonStyle.filled())
	}

	@ViewBuilder
	var signUpTextButton: some View {
		Button {
			Router.shared.navigateTo(.register(ViewModelsFactory.getRegisterViewModel()))
		} label: {
			HStack {
				Text(LocalizableString.dontHaveAccount.localized)
					.font(.system(size: CGFloat(.normalFontSize), weight: .bold))
					.foregroundColor(Color(colorEnum: .text))

				Text(LocalizableString.signUp.localized.uppercased())
					.font(.system(size: CGFloat(.normalFontSize)))
					.foregroundColor(Color(colorEnum: .wxmPrimary))
			}
		}
	}

}

struct Previews_ProfileView_Previews: PreviewProvider {
    static var previews: some View {
		ZStack {
			Color(colorEnum: .bg)

			ProfileView(viewModel: ViewModelsFactory.getProfileViewModel())
		}
    }
}
