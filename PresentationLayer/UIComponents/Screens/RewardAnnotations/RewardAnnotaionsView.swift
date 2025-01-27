//
//  RewardAnnotaionsView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 28/2/24.
//

import SwiftUI
import DomainLayer
import Toolkit

struct RewardAnnotaionsView: View {
	@StateObject var viewModel: RewardAnnotationsViewModel

	var body: some View {
		NavigationContainerView {
			ContentView(viewModel: viewModel)
		}
	}
}

private struct ContentView: View {
	@StateObject var viewModel: RewardAnnotationsViewModel
	@EnvironmentObject var navigationObject: NavigationObject

	var body: some View {
		ZStack {
			Color(colorEnum: .background)
				.ignoresSafeArea()
			ScrollView {
				VStack(spacing: CGFloat(.largeSpacing)) {
					titleView

					annotationsListView
				}
				.padding(.horizontal, CGFloat(.defaultSidePadding))
			}
			.scrollIndicators(.hidden)
		}
		.onAppear {
			navigationObject.navigationBarColor = Color(colorEnum: .background)

			WXMAnalytics.shared.trackScreen(.rewardIssues)
		}
	}
}

private extension ContentView {
	@ViewBuilder
	var titleView: some View {
		VStack(spacing: CGFloat(.minimumSpacing)) {
			HStack {
				Text(LocalizableString.RewardDetails.rewardIssues.localized)
					.foregroundColor(Color(.text))
					.font(.system(size: CGFloat(.titleFontSize), weight: .bold))
				Spacer()
			}

			HStack {
				Text(LocalizableString.RewardDetails.reportFor(viewModel.refDate.getFormattedDate(format: .monthLiteralDayYear,
																								  timezone: .UTCTimezone,
																								  showTimeZoneIndication: true).capitalizedSentence).localized)
					.foregroundColor(Color(.darkGrey))
					.font(.system(size: CGFloat(.normalFontSize)))
				Spacer()
			}

		}
	}

	@ViewBuilder
	var annotationsListView: some View {
		VStack(spacing: CGFloat(.mediumSpacing)) {
			ForEach(viewModel.annotations) { annotation in
				CardWarningView(configuration: .init(type: annotation.warningType ?? .warning,
													 showIcon: false,
													 title: annotation.title ?? "",
													 message: annotation.message ?? "",
													 showBorder: true,
													 closeAction: nil)) {
					actionView(for: annotation)
						.padding(.top, CGFloat(.smallSidePadding))
				}
			}
		}
	}

	@ViewBuilder
	func actionView(for error: RewardAnnotation) -> some View {
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
	RewardAnnotaionsView(viewModel: ViewModelsFactory.getRewardAnnotationsViewModel(device: .mockDevice,
																					annotations: [.init(severity: .warning,
																										group: .noWallet,
																										title: "Wallet annotation",
																										message: "Wallet annotation message",
																										docUrl: "url"),
																								  .init(severity: .error,
																										group: .noWallet,
																										title: "Wallet annotation",
																										message: "Wallet annotation message",
																										docUrl: "url")],
																					followState: .init(deviceId: "", relation: .owned),
																					refDate: .now))
}
