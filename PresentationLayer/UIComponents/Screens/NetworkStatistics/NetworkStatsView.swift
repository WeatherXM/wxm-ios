//
//  NetworkStatsView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 9/6/23.
//

import SwiftUI
import Toolkit

struct NetworkStatsView: View {

    @StateObject var viewModel: NetworkStatsViewModel
    @EnvironmentObject var navigationObject: NavigationObject
    @StateObject private var scrollObject = TrackableScrollOffsetObject()

    var body: some View {
        ZStack {
            Color(colorEnum: .bg)
                .ignoresSafeArea()

            contentView
				.iPadMaxWidth()
                .spinningLoader(show: Binding(get: { viewModel.state == .loading }, set: { _ in }), hideContent: true)
                .wxmEmptyView(show: Binding(get: { viewModel.state == .empty }, set: { _ in }),
                              configuration: .init(title: LocalizableString.NetStats.emptyTitle.localized.uppercased(),
                                                   description: LocalizableString.NetStats.emptyDescription.localized.attributedMarkdown ?? "",
                                                   buttonTitle: LocalizableString.reload.localized) { viewModel.handleRetryButtonTap() })
                .fail(show: Binding(get: { viewModel.state == .fail}, set: { _ in }), obj: viewModel.failObj)
        }
        .transition(.opacity)
        .onAppear {
            navigationObject.navigationBarColor = Color(colorEnum: .bg)
            navigationObject.title = LocalizableString.NetStats.networkStatistics.localized

            WXMAnalytics.shared.trackScreen(.networkStats)
        }
        .bottomSheet(show: $viewModel.showInfo, fitContent: true) {
			bottomInfoView(info: viewModel.info)
        }
    }
}

private extension NetworkStatsView {
    @ViewBuilder
    var contentView: some View {
        TrackableScrollView(offsetObject: scrollObject) { completion in
            viewModel.refresh(completion: completion)
        } content: {
            VStack(spacing: CGFloat(.mediumSpacing)) {
                dataDaysView
                rewardsView
                buyStationView
                tokenView
                weatherStationsView
                manufacturerView
                lastUpdatedView
            }
            .padding(CGFloat(.defaultSidePadding))
        }
    }
}

struct NetworkStatsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationContainerView {
            NetworkStatsView(viewModel: ViewModelsFactory.getNetworkStatsViewModel())
        }
    }
}

struct NetworkStatsViewEmpty_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = NetworkStatsViewModel()
        viewModel.state = .empty
        return NavigationContainerView {
            NetworkStatsView(viewModel: viewModel)
        }
    }
}
