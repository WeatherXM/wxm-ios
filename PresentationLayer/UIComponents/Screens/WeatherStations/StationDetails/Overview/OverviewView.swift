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
					HStack(spacing: CGFloat(.smallSpacing)) {
						Text(LocalizableString.StationDetails.stationHealth.localized)
							.font(.system(size: CGFloat(.mediumFontSize), weight: .bold))
							.foregroundStyle(Color(colorEnum: .darkestBlue))

						Button {
							viewModel.handleStationHealthInfoTap()
						} label: {
							Text(FontIcon.infoCircle.rawValue)
								.font(.fontAwesome(font: .FAPro, size: CGFloat(.mediumFontSize)))
								.foregroundColor(Color(colorEnum: .wxmPrimary))
						}

						Spacer()

						if viewModel.shouldShowAIAssistantButton {
							aiSupportView
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

	@ViewBuilder
	var aiSupportView: some View {
		Button {
			viewModel.handleAISupportTap()
		} label: {
			HStack(spacing: CGFloat(.minimumSpacing)) {
				Text(FontIcon.sparkles.rawValue)
					.font(.fontAwesome(font: .FAProSolid, size: CGFloat(.mediumFontSize)))

				Text(LocalizableString.StationDetails.aiHealthCheck.localized)
					.font(.system(size: CGFloat(.caption), weight: .bold))
			}
			.foregroundStyle(Color(colorEnum: .textDarkStable))
			.padding(CGFloat(.smallSidePadding))
			.background {
				LinearGradient(
					stops: [
						Gradient.Stop(color: Color(red: 0.91, green: 0.59, blue: 0.69), location: 0.00),
						Gradient.Stop(color: Color(red: 0.73, green: 0.53, blue: 0.89), location: 0.25),
						Gradient.Stop(color: Color(red: 0.51, green: 0.71, blue: 0.86), location: 0.63),
						Gradient.Stop(color: Color(red: 0.41, green: 0.46, blue: 0.84), location: 1.00),
					],
					startPoint: UnitPoint(x: 0, y: 0.5),
					endPoint: UnitPoint(x: 1, y: 0.5))
			}
			.cornerRadius(CGFloat(.cardCornerRadius))
		}
		.wxmShadow()
	}
}

struct OverviewView_Previews: PreviewProvider {
    static var previews: some View {
		OverviewView(viewModel: ViewModelsFactory.getStationOverviewViewModel(device: .mockDevice, delegate: nil))
    }
}
