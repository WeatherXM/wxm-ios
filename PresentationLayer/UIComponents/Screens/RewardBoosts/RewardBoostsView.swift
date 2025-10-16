//
//  RewardBoostsView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 6/3/24.
//

import SwiftUI
import Toolkit
import DomainLayer

struct RewardBoostsView: View {
	@StateObject var viewModel: RewardBoostsViewModel
	@EnvironmentObject var navigationObject: NavigationObject

    var body: some View {
		ZStack {
			Color(colorEnum: .background)

			TrackableScroller(showIndicators: false) { completion in
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
				WXMAnalytics.shared.trackScreen(.boostDetail)
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

				if let details = viewModel.response?.details, viewModel.shouldShowDetailsDescription {
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
					if viewModel.shouldShowDetailsDescription {
						Divider()
							.overlay(Color(colorEnum: .layer2))
					}

					BoostDetailsView(items: getDetailsItems(details: details))
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
			.buttonStyle(WXMButtonStyle(fillColor: .layer1, strokeColor: .noColor))
		}
		.WXMCardStyle()
	}

	func getDetailsItems(details: NetworkDeviceRewardBoostsResponse.Details) -> [BoostDetailsView.Item] {
		var items = [BoostDetailsView.Item]()

		if let stationHours = details.stationHours {
			items.append(.init(title: LocalizableString.Boosts.rewardableStationHours.localized,
							   value: stationHours.localizedFormatted))
		}

		if let maxDailyReward = details.maxDailyReward {
			items.append(.init(title: LocalizableString.Boosts.dailyTokensToBeRewarded.localized,
							   value: "\(maxDailyReward.toWXMTokenPrecisionString) \(StringConstants.wxmCurrency)"))
		}

		if let maxTotalReward = details.maxTotalReward {
			items.append(.init(title: LocalizableString.Boosts.totalTokensToBeRewarded.localized,
							   value: "\(maxTotalReward.toWXMTokenPrecisionString) \(StringConstants.wxmCurrency)"))
		}

		items.append(.init(title: LocalizableString.Boosts.boostPeriod.localized,
						   value: "\(details.boostStartDateString) -  \(details.boostStopDateString)"))

		return items
	}
}

#Preview {
	NavigationContainerView {
		RewardBoostsView(viewModel: ViewModelsFactory.getRewardsBoostViewModel(boost: .mock,
																			   device: .mockDevice,
																			   date: .now))
	}
}
