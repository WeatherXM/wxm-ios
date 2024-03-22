//
//  RewardBoostsView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 6/3/24.
//

import SwiftUI
import Toolkit

struct RewardBoostsView: View {
	@StateObject var viewModel: RewardBoostsViewModel
	@EnvironmentObject var navigationObject: NavigationObject

    var body: some View {
		ZStack {
			Color(colorEnum: .background)

			TrackableScrollView { completion in
				viewModel.refresh(completion: completion)
			} content: {
				VStack(spacing: CGFloat(.mediumSpacing)) {
					BoostCardView(boost: viewModel.boost)
						.wxmShadow()

					VStack(spacing: CGFloat(.mediumSpacing)) {
						detailsView
							.wxmShadow()

						aboutView
							.wxmShadow()
					}
				}
				.padding(CGFloat(.mediumSidePadding))
			}
			.spinningLoader(show: .init(get: { viewModel.state == .loading }, set: { _ in }), hideContent: true)
			.fail(show: .init(get: { viewModel.state == .fail }, set: { _ in }), obj: viewModel.failObj)
			.iPadMaxWidth()
			.onAppear {
				navigationObject.navigationBarColor = Color(colorEnum: .background)
				Logger.shared.trackScreen(.analytics, parameters: [.itemId: .custom(viewModel.response?.code?.rawValue ?? "")])
			}
		}
    }
}

private extension RewardBoostsView {
	@ViewBuilder
	var detailsView: some View {
		VStack(spacing: CGFloat(.defaultSpacing)) {
			VStack(spacing: CGFloat(.minimumSpacing)) {
				HStack {
					Text(LocalizableString.Boosts.boostDetails.localized)
						.font(.system(size: CGFloat(.normalFontSize), weight: .medium))
						.foregroundColor(Color(.text))
					Spacer()
				}

				if let details = viewModel.response?.details {
					HStack {
						Text(LocalizableString.Boosts.boostDetailsDescription(details.participationStartDateString, details.participationStopDateString).localized)
							.font(.system(size: CGFloat(.normalFontSize)))
							.foregroundColor(Color(.text))
							.fixedSize(horizontal: false, vertical: true)
						Spacer()
					}
				}
			}

			if let details = viewModel.response?.details {
				VStack(spacing: CGFloat(.smallSpacing)) {
					Divider()
						.overlay(Color(colorEnum: .layer2))

					detailsFieldView(title: LocalizableString.Boosts.rewardableStationHours.localized,
									 value: (details.stationHours ?? 0).localizedFormatted)

					Divider()
						.overlay(Color(colorEnum: .layer2))

					detailsFieldView(title: LocalizableString.Boosts.dailyTokensToBeRewarded.localized,
									 value: "\((details.maxDailyReward ?? 0.0).toWXMTokenPrecisionString) \(StringConstants.wxmCurrency)")

					Divider()
						.overlay(Color(colorEnum: .layer2))

					detailsFieldView(title: LocalizableString.Boosts.totalTokensToBeRewarded.localized,
									 value: "\((details.maxTotalReward ?? 0.0).toWXMTokenPrecisionString) \(StringConstants.wxmCurrency)")

					Divider()
						.overlay(Color(colorEnum: .layer2))

					detailsFieldView(title: LocalizableString.Boosts.boostPeriod.localized,
									 value: "\(details.boostStartDateString) -  \(details.boostStopDateString)")

					Divider()
						.overlay(Color(colorEnum: .layer2))
				}
			}
		}
		.WXMCardStyle()
	}

	@ViewBuilder
	func detailsFieldView(title: String, value: String) -> some View {
		HStack {
			Text(title)
				.font(.system(size: CGFloat(.normalFontSize)))
				.foregroundColor(Color(colorEnum: .text))
				.fixedSize(horizontal: false, vertical: true)

			Spacer()

			Text(value)
				.lineLimit(1)
				.font(.system(size: CGFloat(.caption), weight: .medium))
				.foregroundColor(Color(colorEnum: .text))
				.fixedSize()
		}
	}

	@ViewBuilder
	var aboutView: some View {
		VStack(spacing: CGFloat(.smallSpacing)) {
			HStack {
				Text(LocalizableString.about.localized)
					.font(.system(size: CGFloat(.normalFontSize), weight: .medium))
					.foregroundColor(Color(colorEnum: .text))
				Spacer()
			}

			HStack {
				Text(viewModel.response?.metadata?.about ?? "")
					.font(.system(size: CGFloat(.normalFontSize)))
					.foregroundColor(Color(colorEnum: .text))
				Spacer()
			}

			Button {
				viewModel.handleReadMoreTap()
			} label: {
				Text(LocalizableString.RewardDetails.readMore.localized)
			}
			.buttonStyle(WXMButtonStyle(fillColor: .layer1, strokeColor: .clear))
		}
		.WXMCardStyle()
	}
}

#Preview {
	NavigationContainerView {
		RewardBoostsView(viewModel: ViewModelsFactory.getRewardsBoostViewModel(boost: .mock,
																			   device: .mockDevice,
																			   date: .now))
	}
}
