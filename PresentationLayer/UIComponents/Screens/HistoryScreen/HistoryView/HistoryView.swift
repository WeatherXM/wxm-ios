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
			TrackableScroller(showIndicators: false) { completion in
				viewModel.refresh(completion: completion)
			} content: {
				Group {
					VStack(spacing: CGFloat(.largeSpacing)) {
						ProBannerView(description: LocalizableString.Promotional.unlockFullWeather.localized,
									  analyticsSource: .localHistory)

						if let historyData = viewModel.currentHistoryData, !historyData.isEmpty() {
							ChartsContainer(historyData: historyData,
											chartTypes: ChartCardType.allCases,
											delegate: viewModel.chartDelegate)
							.id(historyData.markDate)
						}
					}
					.padding(.horizontal, CGFloat(.defaultSidePadding))
					.padding(.top, CGFloat(.defaultSidePadding))
				}
			}
			.iPadMaxWidth()
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
			HistoryView(viewModel: ViewModelsFactory.getHistoryViewModel(device: DeviceDetails.mockDevice, date: .now))
        }
    }
}
