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
			.bottomSheet(show: $viewModel.showInfo, fitContent: true) {
				bottomInfoView(info: viewModel.info)
			}
	}

	@ViewBuilder
	var content: some View {
		ZStack {
			Color(colorEnum: .bg)
				.ignoresSafeArea()

			TrackableScrollView {
				VStack(spacing: CGFloat(.defaultSpacing)) {
					VStack(spacing: CGFloat(.defaultSpacing)) {
						DailyRewardCardView(card: viewModel.rewardSummary.toDailyRewardCard, buttonAction: {})

						if viewModel.rewardSummary.annotationSummary?.isEmpty != true {
							errorsList
						}
					}
					.WXMCardStyle()

					if viewModel.followState?.relation == .owned {
						Button {
							viewModel.handleContactSupportTap()
						} label: {
							Text(LocalizableString.RewardDetails.contactSupportButtonTitle.localized)
						}
						.buttonStyle(WXMButtonStyle.solid)
					}
				}
				.iPadMaxWidth()
				.padding(.horizontal, CGFloat(.defaultSidePadding))
			}
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
	var errorsList: some View {
		VStack(spacing: CGFloat(.mediumSpacing)) {
			HStack {
				Text(LocalizableString.RewardDetails.problemsTitle.localized)
					.foregroundColor(Color(colorEnum: .darkestBlue))
					.font(.system(size: CGFloat(.smallTitleFontSize), weight: .bold))
				Spacer()
			}

			HStack {
				Text(viewModel.problemsDescription.attributedMarkdown ?? "")
					.foregroundColor(Color(colorEnum: .text))
					.font(.system(size: CGFloat(.normalFontSize)))
				Spacer(minLength: 0.0)
			}

			ForEach(viewModel.rewardSummary.annotationSummary ?? []) { error in
				CardWarningView(type: error.severity?.toCardWarningType ?? .info,
								title: error.title,
								message: error.message ?? "",
								showContentFullWidth: true,
								showBorder: true,
								closeAction: nil) {
					errorActionView(for: error)
				}
			}
		}
	}
}

private extension ContentView {
	@ViewBuilder
	func errorActionView(for error: RewardAnnotation) -> some View {
		if let title = viewModel.annotationActionButtonTile(for: error) {
			Button {
				viewModel.handleButtonTap(for: error)
			} label: {
				Text(title)
			}
			.buttonStyle(WXMButtonStyle.transparent)
		} else {
			EmptyView()
		}
	}
}

#Preview {
	let device = DeviceDetails.mockDevice
	return ZStack {
		Color(colorEnum: .bg)
		RewardDetailsView(viewModel: .init(device: device,
										   followState: .init(deviceId: device.id!, relation: .owned),
										   tokenUseCase: SwinjectHelper.shared.getContainerForSwinject().resolve(RewardsTimelineUseCase.self)!,
										   summary: .mock))
	}
}
