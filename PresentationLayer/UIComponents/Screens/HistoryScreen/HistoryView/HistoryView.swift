//
//  HistoryView.swift
//  PresentationLayer
//
//  Created by Lampros Zouloumis on 23/8/22.
//

import DomainLayer
import SwiftUI
import Toolkit

struct HistoryView: View {
    @EnvironmentObject var navigationObject: NavigationObject
    @StateObject var viewModel: HistoryViewModel

    var body: some View {
        ZStack {
            TrackableScrollView(offsetObject: viewModel.scrollObject) { completion in
                viewModel.refresh(completion: completion)
            } content: {
                if let historyData = viewModel.currentHistoryData, !historyData.isEmpty() {
                    ChartsContainer(historyData: historyData, delegate: viewModel.chartDelegate)
						.padding(.horizontal, CGFloat(.defaultSidePadding))
                        .id(historyData.markDate)
						.iPadMaxWidth()
                        .padding(.top)
                }
            }
        }
        .wxmEmptyView(show: Binding(get: { viewModel.currentHistoryData?.isEmpty() ?? true }, set: { _ in }),
                      configuration: .init(animationEnum: .emptyGeneric,
                                           title: LocalizableString.StationDetails.noWeatherData.localized,
                                           description: viewModel.getNoDataDateFormat().attributedMarkdown ?? ""))

        .spinningLoader(show: $viewModel.loadingData, hideContent: true)
        .fail(show: $viewModel.isFailed, obj: viewModel.failObj)
        .onAppear {
            viewModel.refresh(force: false, showFullScreenLoader: true) {
                
            }
        }
    }
}

struct Previews_HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationContainerView {
            HistoryView(viewModel: ViewModelsFactory.getHistoryViewModel(device: DeviceDetails.emptyDeviceDetails, date: .now))
        }
    }
}
