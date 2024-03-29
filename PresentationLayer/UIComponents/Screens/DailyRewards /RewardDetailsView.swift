//
//  RewardDetailsView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 31/10/23.
//

import SwiftUI
import DomainLayer
import Toolkit

struct RewardDetailsView: View {

	@StateObject var viewModel: RewardDetailsViewModel

    var body: some View {
		NavigationContainerView {
			ContentView(viewModel: viewModel)
		}
    }
}

private struct ContentView: View {

	@ObservedObject var viewModel: RewardDetailsViewModel
	@EnvironmentObject var navigationObject: NavigationObject

	var body: some View {
		content
	}

	@ViewBuilder
	var content: some View {
		ZStack {
			Color(colorEnum: .background)
				.ignoresSafeArea()

			TrackableScrollView { completion in
				viewModel.refresh(completion: completion)
			} content: {
				VStack(spacing: CGFloat(.defaultSpacing)) {
					titleView

					issuesView

					baseRewardView

					boostsView
				}
				.iPadMaxWidth()
				.padding(.horizontal, CGFloat(.mediumSidePadding))
				.padding(.bottom, CGFloat(.smallSidePadding))
			}
			.spinningLoader(show: .init(get: { viewModel.state == .loading }, set: { _ in }),
							hideContent: true)
			.fail(show: .init(get: { viewModel.state == .fail }, set: { _ in }), 
				  obj: viewModel.failObj)
			.onAppear {
				navigationObject.titleColor = Color(colorEnum: .text)
				navigationObject.navigationBarColor = Color(colorEnum: .background)

				Logger.shared.trackScreen(.deviceRewardsDetails)
			}
		}
		.bottomSheet(show: $viewModel.showInfo) {
			bottomInfoView(info: viewModel.info)
		}
	}

	@ViewBuilder
	var titleView: some View {
		VStack(spacing: CGFloat(.mediumSpacing)) {
			VStack(spacing: 0.0) {
				HStack {
					Text(LocalizableString.RewardDetails.dailyReward.localized)
						.font(.system(size: CGFloat(.titleFontSize), weight: .bold))
						.foregroundColor(Color(.text))

					Button {
						viewModel.handleDailyRewardInfoTap()
					} label: {
						Text(FontIcon.infoCircle.rawValue)
							.font(.fontAwesome(font: .FAPro, size: CGFloat(.mediumFontSize)))
							.foregroundColor(Color(.text))
					}

					Spacer()
				}
				
				HStack {
					Text(viewModel.dateString)
						.font(.system(size: CGFloat(.normalFontSize)))
						.foregroundColor(Color(.darkGrey))
					Spacer()
				}
			}

			if let rewards = viewModel.rewardDetailsResponse?.totalDailyReward {
				HStack {
					Text("+ \(rewards.toWXMTokenPrecisionString) \(StringConstants.wxmCurrency)")
						.lineLimit(1)
						.font(.system(size: CGFloat(.XLTitleFontSize), weight: .bold))
						.foregroundColor(Color(colorEnum: .darkestBlue))

					Spacer()
				}
			}

		}
	}

	@ViewBuilder
	var issuesView: some View {
		if let mainAnnotation = viewModel.rewardDetailsResponse?.mainAnnotation {
			VStack(spacing: CGFloat(.mediumSpacing)) {
				VStack(spacing: CGFloat(.minimumSpacing)) {
					HStack {
						Text(LocalizableString.RewardDetails.issues.localized)
							.font(.system(size: CGFloat(.titleFontSize), weight: .bold))
							.foregroundColor(Color(.text))
						Spacer()
					}

					if let subtitle = viewModel.issuesSubtitle()?.attributedMarkdown {
						HStack {
							Text(subtitle)
								.font(.system(size: CGFloat(.normalFontSize)))
								.foregroundColor(Color(.darkGrey))
								.fixedSize(horizontal: false, vertical: true)
							Spacer()
						}
					}
				}


				CardWarningView(type: mainAnnotation.warningType ?? .warning,
								showIcon: false,
								title: mainAnnotation.title ?? "",
								message: mainAnnotation.message ?? "",
								showBorder: true,
								closeAction: nil) {
					Button {
						viewModel.handleIssueButtonTap()
					} label: {
						Text(viewModel.issuesButtonTitle() ?? "")
					}
					.buttonStyle(WXMButtonStyle.transparent)
					.padding(.top, CGFloat(.smallSidePadding))
				}.wxmShadow()
			}
		} else {
			EmptyView()
		}
	}

	@ViewBuilder
	var baseRewardView: some View {
		if let base = viewModel.rewardDetailsResponse?.base {
			VStack(spacing: CGFloat(.mediumSpacing)) {
				VStack(spacing: CGFloat(.minimumSpacing)) {
					HStack {
						Text(LocalizableString.StationDetails.baseReward.localized)
							.font(.system(size: CGFloat(.titleFontSize), weight: .bold))
							.foregroundColor(Color(.text))
						Spacer()
					}

					if let subtitle = viewModel.baseRewardSubtitle()?.attributedMarkdown {
						HStack {
							Text(subtitle)
								.font(.system(size: CGFloat(.normalFontSize)))
								.foregroundColor(Color(.darkGrey))
								.fixedSize(horizontal: false, vertical: true)
							Spacer()
						}
					}
				}

				VStack(spacing: CGFloat(.mediumSpacing)) {
					if let scoreObject = viewModel.dataQualityScoreObject {
						RewardFieldView(title: LocalizableString.RewardDetails.dataQuality.localized,
										score: scoreObject) {
							viewModel.handleDataQualityInfoTap()
						}
										.wxmShadow()
					}

					locationQualityGrid
				}
			}
		} else{
			EmptyView()
		}
	}

	@ViewBuilder
	var locationQualityGrid: some View {
		LazyVGrid(columns: [.init(alignment: .top), .init(alignment: .top)],
				  spacing: CGFloat(.mediumSpacing)) {
			if let scoreObject = viewModel.locationQualityScoreObject {
				RewardFieldView(title: LocalizableString.RewardDetails.locationQuality.localized,
								score: scoreObject) {
					viewModel.handleLocationQualityInfoTap()
				}
								.wxmShadow()
			}

			if let scoreObject = viewModel.cellPositionScoreObject {
				RewardFieldView(title: LocalizableString.RewardDetails.cellPosition.localized,
								score: scoreObject) {
					viewModel.handleCellPositionInfoTap()
				}
								.wxmShadow()
			}
		}
	}

	@ViewBuilder
	var boostsView: some View {
		VStack(spacing: CGFloat(.mediumSpacing)) {
			VStack(spacing: CGFloat(.minimumSpacing)) {
				HStack {
					Text(LocalizableString.RewardDetails.activeBoosts.localized)
						.font(.system(size: CGFloat(.titleFontSize), weight: .bold))
						.foregroundColor(Color(.text))
					Spacer()
				}

				if let subtitle = viewModel.boostsSubtitle()?.attributedMarkdown {
					HStack {
						Text(subtitle)
							.font(.system(size: CGFloat(.normalFontSize)))
							.foregroundColor(Color(.darkGrey))
							.fixedSize(horizontal: false, vertical: true)
						Spacer()
					}
				}
			}

			if let data = viewModel.rewardDetailsResponse?.boost?.data,
			   !data.isEmpty {
				ForEach(data, id: \.code) { boost in
					BoostsView(title: boost.title ?? "",
							   description: boost.description ?? "",
							   rewards: boost.actualReward ?? 0.0,
							   imageUrl: boost.imageUrl ?? "")
					.wxmShadow()
					.onTapGesture {
						viewModel.handleBoostTap(boost: boost)
					}
				}
			} else {
				NoBoostsView()
					.wxmShadow()
			}
		}
	}
}

#Preview {
	let device = DeviceDetails.mockDevice
	return ZStack {
		Color(colorEnum: .bg)
		RewardDetailsView(viewModel: .init(device: device,
										   followState: .init(deviceId: device.id!, relation: .owned),
										   date: .now,
										   tokenUseCase: SwinjectHelper.shared.getContainerForSwinject().resolve(RewardsTimelineUseCase.self)!))
	}
}
