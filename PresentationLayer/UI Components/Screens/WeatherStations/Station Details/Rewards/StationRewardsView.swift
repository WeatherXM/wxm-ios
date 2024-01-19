//
//  RewardsView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 20/3/23.
//

import SwiftUI
import Toolkit
struct StationRewardsView: View {
    @StateObject var viewModel: StationRewardsViewModel

    var body: some View {
		GeometryReader { proxy in
			ZStack {
				TrackableScrollView(offsetObject: viewModel.offsetObject) { completion in
					viewModel.refresh(completion: completion)
				} content: {
					VStack(spacing: CGFloat(.mediumSpacing)) {
						VStack(spacing: CGFloat(.largeSpacing)) {
							if let data = viewModel.data {
								StationRewardsCardView(selectedIndex: $viewModel.selectedIndex,
													   totalRewards: viewModel.totalRewards,
													   showErrorButtonAction: true,
													   overviews: data,
													   buttonActions: viewModel.cardButtonActions)
								.wxmShadow()
							}

							VStack(spacing: CGFloat(.defaultSpacing)) {
								Button {
									viewModel.handleDetailedRewardsButtonTap()
								} label: {
									Text(LocalizableString.StationDetails.detailedRewardsButtonTitle.localized)
								}
								.buttonStyle(WXMButtonStyle.solid)

								InfoView(text: LocalizableString.StationDetails.rewardsInfoText.localized.attributedMarkdown ?? "")
							}
						}
						.animation(.easeIn, value: viewModel.selectedIndex)
					}
					.padding()
					.padding(.bottom, proxy.size.height / 2.0) // Quick fix for better experience while expanding/collapsing the containers's header
					#warning("TODO: Find a better solution")
				}
				.spinningLoader(show: Binding(get: { viewModel.viewState == .loading }, set: { _ in }), hideContent: true)
				.fail(show: Binding(get: { viewModel.viewState == .fail }, set: { _ in }), obj: viewModel.failObj)
			}
		}
		.bottomSheet(show: $viewModel.showInfo, fitContent: true) {
			bottomInfoView(info: viewModel.info)
		}
        .onAppear {
            Logger.shared.trackScreen(.rewards)
        }
    }
}

struct RewardsView_Previews: PreviewProvider {
    static var previews: some View {
        StationRewardsView(viewModel: StationRewardsViewModel(deviceId: "", useCase: nil))
			.background(Color.red)
    }
}
