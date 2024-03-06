//
//  RewardBoostsView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 6/3/24.
//

import SwiftUI

struct RewardBoostsView: View {
	@StateObject var viewModel: RewardBoostsViewModel

    var body: some View {
		TrackableScrollView { completion in
			viewModel.refresh(completion: completion)
		} content: {
			VStack(spacing: CGFloat(.mediumSpacing)) {
				BoostCardView(boost: viewModel.boost)
					.wxmShadow()

				VStack(spacing: CGFloat(.mediumSpacing)) {
					detailsView
						.wxmShadow()
				}
			}
			.padding(CGFloat(.mediumSidePadding))
		}
		.spinningLoader(show: .init(get: { viewModel.state == .loading }, set: { _ in }), hideContent: true)
		.fail(show: .init(get: { viewModel.state == .fail }, set: { _ in }), obj: viewModel.failObj)
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
						Spacer()
					}
				}
			}

			if let details = viewModel.response?.details {
				VStack(spacing: CGFloat(.smallSpacing)) {
					Divider()
						.overlay(Color(colorEnum: .layer2))

					detailsFieldView(title: LocalizableString.Boosts.rewardableStationHours.localized,
									 value: "\(details.stationHours ?? 0)")

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

			Spacer()

			Text(value)
				.font(.system(size: CGFloat(.caption), weight: .medium))
				.foregroundColor(Color(colorEnum: .text))
		}
	}
}

#Preview {
	RewardBoostsView(viewModel: ViewModelsFactory.getRewardsBoostViewModel(boost: .mock,
																		   device: .mockDevice,
																		   date: .now))
}
