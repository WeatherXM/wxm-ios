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
        HStack(spacing: CGFloat(.smallSpacing)) {
			Text("\(forecast.daily?.temperatureMin?.toTemeratureString(for: unitsManager.temperatureUnit) ?? "")")
				.font(.system(size: CGFloat(.mediumFontSize), weight: .bold))

            CustomRangeSlider(minWeeklyTemp: minWeekTemperature.toTemeratureUnit(unitsManager.temperatureUnit).rounded(toPlaces: 0),
                              maxWeeklyTemp: maxWeekTemperature.toTemeratureUnit(unitsManager.temperatureUnit).rounded(toPlaces: 0),
                              minDailyTemp: forecast.daily?.temperatureMin?.toTemeratureUnit(unitsManager.temperatureUnit).rounded(toPlaces: 0) ?? 0.0,
                              maxDailyTemp: forecast.daily?.temperatureMax?.toTemeratureUnit(unitsManager.temperatureUnit).rounded(toPlaces: 0) ?? 0.0)
            
			Text("\(forecast.daily?.temperatureMax?.toTemeratureString(for: unitsManager.temperatureUnit) ?? "")")
				.font(.system(size: CGFloat(.titleFontSize), weight: .bold))
        }
    }

    @ViewBuilder
    func fieldView(for field: WeatherField) -> some View {
        if let weather = forecast.daily {
			let hourlyIcon = field.hourlyIcon(from: weather)
            HStack(spacing: 0.0) {
				Image(asset: hourlyIcon.icon)
					.resizable()
                    .renderingMode(.template)
                    .foregroundColor(Color(colorEnum: .darkGrey))
					.frame(width: 20.0, height: 20.0)
					.rotationEffect(Angle(degrees: hourlyIcon.rotation))

                Text(getFieldText(weatherField: field,
                                  weather: weather,
                                  unitsManager: unitsManager))
                .font(.system(size: CGFloat(.caption)))
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
}
