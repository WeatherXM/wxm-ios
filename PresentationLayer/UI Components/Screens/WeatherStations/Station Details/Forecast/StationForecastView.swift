//
//  StationForecastView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 16/3/23.
//

import SwiftUI
import DomainLayer
import Toolkit

struct StationForecastView: View {
    @StateObject var viewModel: StationForecastViewModel
    @State private var expandedForecasts: Set<String>?

    var body: some View {
        ZStack {
            ScrollViewReader { proxy in
                TrackableScrollView(showIndicators: false, offsetObject: viewModel.offsetObject) { completion in
                    viewModel.refresh(completion: completion)
                } content: {
                    VStack(spacing: CGFloat(.smallSpacing)) {
                        ForEach(viewModel.forecasts, id: \.date) { forecast in
                            StationForecastCardView(forecast: forecast,
                                                    minWeekTemperature: viewModel.overallMinTemperature ?? 0.0,
                                                    maxWeekTemperature: viewModel.overallMaxTemperature ?? 0.0,
                                                    isExpanded: Binding(get: { expandedForecasts?.contains(forecast.date) == true },
                                                                        set: { _ in
                                withAnimation(.easeIn(duration: 0.3)) {
                                    let isExpanded = expandCollapseCard(for: forecast.date)
                                    if  isExpanded {
                                        proxy.scrollTo(forecast.date, anchor: .top)
                                    }
                                    viewModel.trackSelectContentEvent(forecast: forecast, isOpen: isExpanded)
                                }
                            }),
                                                    isExpandable: forecast.hourly?.isEmpty == false)
                            .wxmShadow()
                        }
                    }
					.iPadMaxWidth()
                    .padding()
                }
            }
            .onAppear {
                withAnimation {
                    initializeExpandedForecastsIfNeeded()
                }
            }
        }
        .wxmEmptyView(show: Binding(get: { viewModel.viewState == .hidden }, set: { _ in }), configuration: viewModel.hiddenViewConfiguration)
        .fail(show: Binding(get: { viewModel.viewState == .fail }, set: { _ in }), obj: viewModel.failObj)
        .spinningLoader(show: Binding(get: { viewModel.viewState == .loading }, set: { _ in }), hideContent: true)
        .onAppear {
            Logger.shared.trackScreen(.forecast)
        }
    }
}

private extension StationForecastView {
    /// Expand/collapse the card for the passed date according to its state
    /// - Parameter date: The date to expand or collapse
    /// - Returns: `true` if will be expanded, `false` if not
    func expandCollapseCard(for date: String) -> Bool {
        if expandedForecasts?.contains(date) == true {
            expandedForecasts?.remove(date)
            return false
        }

        expandedForecasts?.insert(date)
        return true
    }

    func initializeExpandedForecastsIfNeeded() {
        guard expandedForecasts == nil else {
            return
        }

        expandedForecasts = []
        if let firstForecast = viewModel.forecasts.first,
           firstForecast.hourly?.isEmpty == false {
            let firstDate = firstForecast.date
            expandedForecasts?.insert(firstDate)
        }
    }
}

struct StationForecastView_Previews: PreviewProvider {
    static var previews: some View {
        let vm = StationForecastViewModel.mockInstance
        Task { @MainActor in
            await vm.refreshWithDevice(.emptyDeviceDetails, followState: .init(deviceId: "", relation: .followed), error: nil)
        }
        return StationForecastView(viewModel: vm)
    }
}
