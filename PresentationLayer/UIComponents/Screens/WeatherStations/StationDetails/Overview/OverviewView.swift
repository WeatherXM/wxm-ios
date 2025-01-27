//
//  OverviewView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 6/3/23.
//

import SwiftUI
import DomainLayer
import Toolkit

struct OverviewView: View {
    @StateObject var viewModel: OverviewViewModel
    @State private var containerSize: CGSize = .zero

    var body: some View {
        ZStack {
			TrackableScroller(showIndicators: false,
							  offsetObject: viewModel.offsetObject) { completion in
                viewModel.refresh(completion: completion)
            } content: {
				VStack(spacing: CGFloat(.defaultSpacing)) {
					stationHealthView

					currentWeatherView

					if let ctaObj = viewModel.ctaObject {
						CTAContainerView(ctaObject: ctaObj)
					}
				}
				.iPadMaxWidth()
				.padding(.top, CGFloat(.mediumToLargeSidePadding))
				.padding(.horizontal, CGFloat(.mediumSidePadding))
				.padding(.bottom, containerSize.height / 2.0) // Quick fix for better experience while expanding/collapsing the containers's header
            }
            .sizeObserver(size: $containerSize)
        }
        .spinningLoader(show: Binding(get: { viewModel.viewState == .loading }, set: { _ in }), hideContent: true)
        .fail(show: Binding(get: { viewModel.viewState == .fail }, set: { _ in }), obj: viewModel.failObj)
		.bottomSheet(show: $viewModel.showStationHealthInfo) {
			StationHealthInfoView() {
				viewModel.handleStationHealthBottomSheetButtonTap()
			}
		}
    }
}

private extension OverviewView {
    @ViewBuilder
    var currentWeatherView: some View {
        if let device = viewModel.device {
			VStack(spacing: CGFloat(.mediumSpacing)) {
				HStack {
					Text(LocalizableString.StationDetails.latestWeather.localized)
						.font(.system(size: CGFloat(.mediumFontSize), weight: .bold))
						.foregroundStyle(Color(colorEnum: .darkestBlue))

					Spacer()
				}

				WeatherOverviewView(weather: device.weather,
									showSecondaryFields: device.weather != nil,
									noDataText: viewModel.weatherNoDataText,
									lastUpdatedText: device.weather?.updatedAtString(with: TimeZone(identifier: device.timezone ?? "") ?? .current),
									buttonTitle: LocalizableString.StationDetails.viewHistoricalData.localized,
									isButtonEnabled: viewModel.followState != nil) {
					viewModel.handleHistoricalDataButtonTap()
				}.wxmShadow()
			}
        }
    }

	@ViewBuilder
	var stationHealthView: some View {
		if let device = viewModel.device {
			VStack(spacing: CGFloat(.defaultSpacing)) {
				VStack(spacing: CGFloat(.mediumSpacing)) {
					HStack {
						Text(LocalizableString.StationDetails.stationHealth.localized)
							.font(.system(size: CGFloat(.mediumFontSize), weight: .bold))
							.foregroundStyle(Color(colorEnum: .darkestBlue))

						Spacer()

						Button {
							viewModel.handleStationHealthInfoTap()
						} label: {
							Text(FontIcon.infoCircle.rawValue)
								.font(.fontAwesome(font: .FAPro, size: CGFloat(.mediumFontSize)))
								.foregroundColor(Color(colorEnum: .wxmPrimary))
						}
					}

					StationHealthView(device: device,
									  dataQualityAction: { viewModel.handleDataQualityTap() },
									  locationAction: { viewModel.handleLocationQualityTap() })
				}

				if viewModel.showNoDataInfo {
					HStack(spacing: CGFloat(.smallToMediumSpacing)) {
						Text(FontIcon.infoCircle.rawValue)
							.font(.fontAwesome(font: .FAPro, size: CGFloat(.mediumFontSize)))
							.foregroundColor(Color(colorEnum: .wxmPrimary))

						Text(LocalizableString.StationDetails.ownedStationNoDataSnackBarMessage.localized)
							.foregroundStyle(Color(colorEnum: .text))
							.font(.system(size: CGFloat(.normalFontSize)))

						Spacer()
					}
					.WXMCardStyle(insideHorizontalPadding: CGFloat(.smallToMediumSpacing),
								  insideVerticalPadding: CGFloat(.smallToMediumSpacing))
					.wxmShadow()
				}
			}
		}
	}
}

struct OverviewView_Previews: PreviewProvider {
    static var previews: some View {
        OverviewView(viewModel: OverviewViewModel.mockInstance)
    }
}
