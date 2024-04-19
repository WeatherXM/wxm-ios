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
	
    let weatherIconDimensions: CGFloat = 50.0

    var body: some View {
        VStack(spacing: CGFloat(.defaultSpacing)) {
            VStack(spacing: CGFloat(.smallToMediumSpacing)) {
				HStack {
					Text(forecast.daily?.timestamp?.getWeekDayAndDate() ?? "-")
						.foregroundColor(Color(colorEnum: .primary))
						.font(.system(size: CGFloat(.normalFontSize)))

					Spacer()

				}

                dailyView
            }
        }
        .WXMCardStyle()
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
                                       maxWeekTemperature: 20.0)
    }
}
