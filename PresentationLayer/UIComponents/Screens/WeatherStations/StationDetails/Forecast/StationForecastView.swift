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

    var body: some View {
        ZStack {
			Color(colorEnum: .bg)
				.ignoresSafeArea()
			
            ScrollViewReader { proxy in
                TrackableScrollView(showIndicators: false, offsetObject: viewModel.offsetObject) { completion in
                    viewModel.refresh(completion: completion)
                } content: {
                    VStack(spacing: CGFloat(.mediumSpacing)) {

						hourlyView

						HStack {
							Text(LocalizableString.Forecast.nextSevenDays.localized)
								.font(.system(size: CGFloat(.mediumFontSize), weight: .bold))
								.foregroundColor(Color(colorEnum: .darkestBlue))

							Spacer()
						}
						.padding(.horizontal)

						VStack(spacing: CGFloat(.mediumSpacing)) {
							ForEach(viewModel.forecasts, id: \.date) { forecast in
								Button {
									viewModel.handleForecastTap(forecast: forecast)
								} label: {
									StationForecastCardView(forecast: forecast,
															minWeekTemperature: viewModel.overallMinTemperature ?? 0.0,
															maxWeekTemperature: viewModel.overallMaxTemperature ?? 0.0)
									.wxmShadow()
								}
								.buttonStyle(.plain)
							}
							.padding(.horizontal)
						}
						.padding(.bottom)
                    }					
					.iPadMaxWidth()
					.padding(.vertical)
                }
            }
        }
        .wxmEmptyView(show: Binding(get: { viewModel.viewState == .hidden }, set: { _ in }), configuration: viewModel.hiddenViewConfiguration)
        .fail(show: Binding(get: { viewModel.viewState == .fail }, set: { _ in }), obj: viewModel.failObj)
        .spinningLoader(show: Binding(get: { viewModel.viewState == .loading }, set: { _ in }), hideContent: true)
        .onAppear {
            WXMAnalytics.shared.trackScreen(.forecast)
        }
    }
}

private extension StationForecastView {
	@ViewBuilder
	var hourlyView: some View {
		let hourlyItems = viewModel.hourlyItems
		if !hourlyItems.isEmpty {
			VStack(spacing: CGFloat(.mediumSpacing)) {
				HStack {
					Text(LocalizableString.Forecast.nextTwentyFourHours.localized)
						.font(.system(size: CGFloat(.mediumFontSize), weight: .bold))
						.foregroundColor(Color(colorEnum: .darkestBlue))

					Spacer()
				}.padding(.horizontal)

				ScrollView(.horizontal, showsIndicators: false) {
					LazyHStack(spacing: CGFloat(.smallSpacing)) {
						ForEach(0..<viewModel.hourlyItems.count, id: \.self) { index in
							let item = viewModel.hourlyItems[index]
							StationForecastMiniCardView(item: item, isSelected: false)
								.wxmShadow()
								.frame(width: StationForecastMiniCardView.defaultWidth)
						}
					}.padding(.horizontal)
				}
				.disableScrollClip()
			}
		} else {
			EmptyView()
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
