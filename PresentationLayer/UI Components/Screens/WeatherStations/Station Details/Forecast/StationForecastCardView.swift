//
//  StationForecastCardView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 16/3/23.
//

import SwiftUI
import DomainLayer
import Toolkit

struct StationForecastCardView: View {
	let mainVM: MainScreenViewModel = .shared
	let unitsManager: WeatherUnitsManager = .default
    let forecast: NetworkDeviceForecastResponse
    let minWeekTemperature: Double
    let maxWeekTemperature: Double
    @Binding var isExpanded: Bool
    let isExpandable: Bool

    let forecastHoulrlyScrollerImageSize: CGFloat = 50.0
    let weatherIconDimensions: CGFloat = 70.0

    var body: some View {
        VStack(spacing: CGFloat(.defaultSpacing)) {
            VStack(spacing: CGFloat(.minimumSpacing)) {
                HStack {
                    Text(forecast.daily?.timestamp?.getWeekDayAndDate() ?? "-")
                        .foregroundColor(Color(colorEnum: .primary))
                        .font(.system(size: CGFloat(.normalFontSize)))

                    Spacer()

                    Image(asset: .downArrow)
                        .renderingMode(.template)
                        .foregroundColor(Color(colorEnum: .primary))
                        .rotationEffect(.degrees(isExpanded ? 180.0 : 0.0))
                }
				.padding(.horizontal, CGFloat(.defaultSidePadding))

                dailyView
                    .WXMCardStyle(backgroundColor: Color(colorEnum: .top),
                                  insideHorizontalPadding: CGFloat(.defaultSidePadding),
                                  insideVerticalPadding: CGFloat(.defaultSidePadding),
								  cornerRadius: CGFloat(.cardCornerRadius))
            }

            if isExpanded {
                hourlyView
                    .padding(.bottom, CGFloat(.smallSidePadding))
            }
        }
		.padding(.top, CGFloat(.smallSidePadding))
        .WXMCardStyle(backgroundColor: Color(colorEnum: .layer1),
                      insideHorizontalPadding: 0.0,
                      insideVerticalPadding: 0.0,
					  cornerRadius: CGFloat(.cardCornerRadius))
        .onTapGesture {
            isExpanded.toggle()
        }
        .allowsHitTesting(isExpandable)
    }
}

struct StationForecastCardView_Previews: PreviewProvider {
    static var previews: some View {
        var forecast = NetworkDeviceForecastResponse()
        let hourlyWeather = CurrentWeather.mockInstance
        forecast.hourly = [hourlyWeather]
        forecast.daily = CurrentWeather.mockInstance
        return StationForecastCardView(forecast: forecast,
                                       minWeekTemperature: 8.0,
                                       maxWeekTemperature: 20.0,
                                       isExpanded: .constant(true),
                                       isExpandable: true)
    }
}
