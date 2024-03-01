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
	@State private var showPopOverMenu: Bool = false

    var body: some View {
		NavigationContainerView {
			navigationBarRightView
		} content: {
			ContentView(viewModel: viewModel)
		}
    }

	@ViewBuilder
	var navigationBarRightView: some View {
		Button {
			Logger.shared.trackEvent(.userAction, parameters: [.actionName: .rewardDetailsPopUp])

			showPopOverMenu = true
		} label: {
			Text(FontIcon.threeDots.rawValue)
				.font(.fontAwesome(font: .FAProSolid, size: CGFloat(.mediumFontSize)))
				.foregroundColor(Color(colorEnum: .primary))
				.frame(width: 30.0, height: 30.0)
		}
		.wxmPopOver(show: $showPopOverMenu) {
			VStack {
				Button { [weak viewModel] in
					showPopOverMenu = false
					viewModel?.handleReadMoreTap()
					Logger.shared.trackEvent(.selectContent, parameters: [.contentType: .rewardDetailsReadMore])
				} label: {
					Text(LocalizableString.RewardDetails.readMore.localized)
						.font(.system(size: CGFloat(.mediumFontSize)))
						.foregroundColor(Color(colorEnum: .text))
				}
			}
			.padding()
			.background(Color(colorEnum: .top).scaleEffect(2.0).ignoresSafeArea())
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
			Color(colorEnum: .bg)
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
				.padding(.horizontal, CGFloat(.defaultSidePadding))
			}
			.fail(show: .init(get: { viewModel.state == .fail }, set: { _ in }), obj: viewModel.failObj)
			.onAppear {
				navigationObject.title = LocalizableString.RewardDetails.title.localized
				navigationObject.subtitle = viewModel.device.displayName
				navigationObject.titleColor = Color(colorEnum: .text)
				navigationObject.navigationBarColor = Color(colorEnum: .bg)

				Logger.shared.trackScreen(.deviceRewardsDetails)
			}
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

					Button{
					} label: {
						Text(FontIcon.infoCircle.rawValue)
							.font(.fontAwesome(font: .FAPro, size: CGFloat(.mediumFontSize)))
							.foregroundColor(Color(.text))
					}

					Spacer()
				}
				
				HStack {
					Text(LocalizableString.RewardDetails.earningsFor("").localized)
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
		if let mainAnnotation = viewModel.rewardDetailsResponse?.annotation?.mainAnnotation {
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
							Spacer()
						}
					}
				}

				VStack(spacing: CGFloat(.mediumSpacing)) {
					if let scoreObject = viewModel.dataQualityScoreObject {
						RewardFieldView(title: LocalizableString.RewardDetails.dataQuality.localized,
										score: scoreObject) {

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
		LazyVGrid(columns: [.init(), .init()], spacing: CGFloat(.mediumSpacing)) {
			if let scoreObject = viewModel.locationQualityScoreObject {
				RewardFieldView(title: LocalizableString.RewardDetails.locationQuality.localized,
								score: scoreObject) {

				}
								.wxmShadow()
			}

			if let scoreObject = viewModel.cellPositionScoreObject {
				RewardFieldView(title: LocalizableString.RewardDetails.cellPosition.localized,
								score: scoreObject) {

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
				}
			} else {
				NoBoostsView()
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
										   tokenUseCase: SwinjectHelper.shared.getContainerForSwinject().resolve(RewardsTimelineUseCase.self)!))
	}
}
