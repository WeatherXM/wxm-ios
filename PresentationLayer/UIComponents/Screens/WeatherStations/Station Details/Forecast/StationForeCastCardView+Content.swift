//
//  StationForecastCardView+Content.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 16/3/23.
//

import SwiftUI
import DomainLayer

extension StationForecastCardView {
    @ViewBuilder
    var dailyView: some View {
        PercentageGridLayoutView(alignments: [.leading, .trailing], firstColumnPercentage: 0.8) {
            Group {
                VStack(alignment: .leading, spacing: CGFloat(.smallSpacing)) {
                    temperatureBar

                    HStack(spacing: 0.0) {
                        ForEach(fields, id: \.self) { field in
                            fieldView(for: field)
                            Spacer(minLength: 0.0)
                        }
                    }
                }

                weatherImage
            }
        }
    }

    @ViewBuilder
    var hourlyView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: CGFloat(.mediumSpacing)) {
                ForEach(forecast.hourly ?? []) { weather in
                    hourlyWeatherView(weather: weather)
                }
            }
        }
        .padding(.horizontal, CGFloat(.defaultSidePadding))
    }
}

private extension StationForecastCardView {
    @ViewBuilder
    var weatherImage: some View {
        Group {
            if let weather = forecast.daily {
                LottieView(animationCase: weather.icon?.getAnimationString() ?? "".getAnimationString(), loopMode: .loop)
            } else {
                LottieView(animationCase: "anim_not_available", loopMode: .loop)
            }
        }
        .frame(width: weatherIconDimensions, height: weatherIconDimensions)
    }

    var fields: [WeatherField] {
		[.precipitationProbability, .dailyPrecipitation, .wind, .humidity]
    }

    @ViewBuilder
    var temperatureBar: some View {
        HStack(spacing: CGFloat(.minimumSpacing)) {
            Text("\(forecast.daily?.temperatureMin?.toTemeratureString(for: unitsManager.temperatureUnit) ?? "")")
            CustomRangeSlider(minWeeklyTemp: minWeekTemperature.toTemeratureUnit(unitsManager.temperatureUnit).rounded(toPlaces: 0),
                              maxWeeklyTemp: maxWeekTemperature.toTemeratureUnit(unitsManager.temperatureUnit).rounded(toPlaces: 0),
                              minDailyTemp: forecast.daily?.temperatureMin?.toTemeratureUnit(unitsManager.temperatureUnit).rounded(toPlaces: 0) ?? 0.0,
                              maxDailyTemp: forecast.daily?.temperatureMax?.toTemeratureUnit(unitsManager.temperatureUnit).rounded(toPlaces: 0) ?? 0.0)
            Text("\(forecast.daily?.temperatureMax?.toTemeratureString(for: unitsManager.temperatureUnit) ?? "")")
        }
        .font(.system(size: CGFloat(.mediumFontSize), weight: .bold))
    }

    @ViewBuilder
    func fieldView(for field: WeatherField) -> some View {
        if let weather = forecast.daily {
            HStack(spacing: 0.0) {
                Image(asset: field.icon)
					.resizable()
                    .renderingMode(.template)
                    .foregroundColor(Color(colorEnum: .darkestBlue))
					.frame(width: 25.0, height: 25.0)

                Text(getFieldText(weatherField: field,
                                  weather: weather,
                                  unitsManager: unitsManager))
                .font(.system(size: CGFloat(.caption),
                              weight: .bold))
                .foregroundColor(Color(colorEnum: .text))
                .fixedSize(horizontal: false, vertical: true)
            }
        } else {
            EmptyView()
        }
    }

    func getFieldText(weatherField: WeatherField,
                      weather: CurrentWeather,
                      unitsManager: WeatherUnitsManager) -> String {
        let literals = weatherField.weatherLiterals(from: weather, unitsManager: unitsManager)
        return "\(literals?.value ?? "")\(weatherField.shouldHaveSpaceWithUnit ? " " : "")\(literals?.unit ?? "")"
    }

    @ViewBuilder
    func hourlyWeatherView(weather: CurrentWeather) -> some View {
        VStack(alignment: .center, spacing: 0.0) {
            Text(weather.timestamp?.getTimeForLatestDateWeatherDetail() ?? "")
                .foregroundColor(Color(colorEnum: .darkestBlue))
                .font(.system(size: CGFloat(.caption)))
            LottieView(animationCase: weather.icon?.getAnimationString() ?? "", loopMode: .loop)
                .frame(width: forecastHoulrlyScrollerImageSize,
                       height: forecastHoulrlyScrollerImageSize)

            let temperature = WeatherField.temperature.weatherLiterals(from: weather, unitsManager: unitsManager)
            Text("\(temperature?.value ?? "")\(temperature?.unit ?? "")")
                .foregroundColor(Color(colorEnum: .darkestBlue))
                .font(.system(size: CGFloat(.mediumFontSize), weight: .bold))

            let feelsLikeTemperature = WeatherField.feelsLike.weatherLiterals(from: weather, unitsManager: unitsManager)
            Text("\(LocalizableString.feelsLike.localized) **\(feelsLikeTemperature?.value ?? "")°**".attributedMarkdown ?? "")
                .foregroundColor(Color(colorEnum: .darkestBlue))
                .font(.system(size: CGFloat(.caption)))

            VStack(alignment: .leading, spacing: CGFloat(.smallSpacing)) {
                ForEach(WeatherField.hourlyFields, id: \.self) { field in
                    hourlyWeatherFieldView(weather: weather, field: field)
                }
            }
			.padding(.top, CGFloat(.smallSidePadding))
        }
    }

    @ViewBuilder
    func hourlyWeatherFieldView(weather: CurrentWeather, field: WeatherField) -> some View {
        if let literals = field.weatherLiterals(from: weather,
                                                unitsManager: unitsManager,
                                                includeDirection: false,
                                                isForHourlyForecast: true) {
            HStack(spacing: 0.0) {
                Image(asset: field.hourlyIcon())
                    .renderingMode(.template)
                    .foregroundColor(Color(colorEnum: .darkestBlue))
                    .rotationEffect(.degrees(field.iconRotation(from: weather)))

                Text("**\(literals.value)**\(field.shouldHaveSpaceWithUnit ? " " : "")\(literals.unit)")
                    .foregroundColor(Color(colorEnum: .darkestBlue))
                    .font(.system(size: CGFloat(.mediumFontSize)))
            }
        } else {
            EmptyView()
        }
    }
}
