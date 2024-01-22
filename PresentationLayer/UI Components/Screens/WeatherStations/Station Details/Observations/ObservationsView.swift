//
//  ObservationsView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 6/3/23.
//

import SwiftUI
import DomainLayer
import Toolkit

struct ObservationsView: View {
    @StateObject var viewModel: ObservationsViewModel
    @State private var containerSize: CGSize = .zero

    var body: some View {
        ZStack {
            TrackableScrollView(showIndicators: false, offsetObject: viewModel.offsetObject) { completion in
                viewModel.refresh(completion: completion)
            } content: {
                LazyVStack { // Embeded in `LazyVStack` to fix iOS 15 UI issues
                    VStack(spacing: CGFloat(.defaultSpacing)) {
                        currentWeatherView
                            .shadow(color: Color(.black).opacity(0.25),
                                    radius: ShadowEnum.stationCard.radius,
                                    x: ShadowEnum.stationCard.xVal,
                                    y: ShadowEnum.stationCard.yVal)

                        if let ctaObj = viewModel.ctaObject {
                            CTAContainerView(ctaObject: ctaObj)
                        }
                    }
					.iPadMaxWidth()
                    .padding()
                    .padding(.bottom, containerSize.height / 2.0) // Quick fix for better experience while expanding/collapsing the containers's header
#warning("TODO: Find a better solution")
                }
            }
            .sizeObserver(size: $containerSize)
        }
        .spinningLoader(show: Binding(get: { viewModel.viewState == .loading }, set: { _ in }), hideContent: true)
        .fail(show: Binding(get: { viewModel.viewState == .fail }, set: { _ in }), obj: viewModel.failObj)
        .onAppear {
            Logger.shared.trackScreen(.currentWeather)
        }
    }
}

private extension ObservationsView {
    @ViewBuilder
    var currentWeatherView: some View {
        if let device = viewModel.device {
            WeatherOverviewView(weather: device.weather,
                                showSecondaryFields: true,
								lastUpdatedText: device.weather?.updatedAtString(with: TimeZone(identifier: device.timezone ?? "") ?? .current),
                                buttonTitle: LocalizableString.StationDetails.viewHistoricalData.localized,
                                isButtonEnabled: viewModel.followState != nil) {
                viewModel.handleHistoricalDataButtonTap()
            }
        } else {
            EmptyView()
        }
    }
}

struct ObservationsView_Previews: PreviewProvider {
    static var previews: some View {
        let mainVM = MainScreenViewModel.shared
        ObservationsView(viewModel: ObservationsViewModel.mockInstance)
    }
}
