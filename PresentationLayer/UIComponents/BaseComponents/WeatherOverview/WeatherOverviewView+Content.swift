//
//  WeatherOverviewView+Content.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 6/3/23.
//

import SwiftUI
import DomainLayer

private extension WeatherField {
	func attributedString(from weather: CurrentWeather?,
						  unitsManager: WeatherUnitsManager,
						  fontSize: CGFloat = CGFloat(.mediumFontSize)) -> AttributedString {
        guard let weather else {
            return ""
        }

        let literals = weatherLiterals(from: weather, unitsManager: unitsManager)
        let value = literals?.value ?? ""
        let unit = literals?.unit ?? ""

        let font = UIFont.systemFont(ofSize: fontSize, weight: .bold)
        var attributedString = AttributedString("\(value)\(shouldHaveSpaceWithUnit ? " " : "")\(unit)")
        attributedString.font = font
        attributedString.foregroundColor = Color(colorEnum: .text)

        if let unitRange = attributedString.range(of: unit) {
            let unitFont = UIFont.systemFont(ofSize: CGFloat(.caption))
            attributedString[unitRange].foregroundColor = Color(colorEnum: .darkGrey)
            attributedString[unitRange].font = unitFont
        }

        return attributedString
    }
}

extension WeatherOverviewView {

	@ViewBuilder
	var weatherDataView: some View {
		HStack(spacing: 0.0) {
			switch mode {
				case .minimal:
					VStack(spacing: 0.0) {
						weatherImage

						Text(attributedTemperatureString)
							.lineLimit(1)
							.fixedSize()
							.minimumScaleFactor(0.8)

						Text(attributedFeelsLikeString)
							.fixedSize()
					}
				case .default, .medium, .large:
					PercentageGridLayoutView(alignments: [.center, .leading], firstColumnPercentage: 0.5) {
						Group {
							VStack(spacing: 0.0) {
								weatherImage

								Text(attributedTemperatureString)
									.lineLimit(1)
									.minimumScaleFactor(0.7)

								Text(attributedFeelsLikeString)
									.minimumScaleFactor(0.7)
							}

							VStack(alignment: .leading, spacing: weatherFieldsSpacing) {
								ForEach(WeatherField.mainFields, id: \.description) { field in
									weatherFieldView(for: field)
								}
							}
						}
					}
			}
		}
	}

	@ViewBuilder
	var noDataView: some View {
		HStack(spacing: CGFloat(.defaultSpacing)) {
			switch mode {
				case .minimal:
					Image(asset: .noDataIcon)
						.renderingMode(.template)
						.foregroundColor(Color(colorEnum: .text))
				case .default, .medium, .large:
					Image(asset: .noDataIcon)
						.renderingMode(.template)
						.foregroundColor(Color(colorEnum: .text))

					VStack(alignment: .leading, spacing: CGFloat(.minimumSpacing)) {
						Text(LocalizableString.stationNoDataTitle.localized)
							.font(.system(size: noDataTitleFontSize, weight: .bold))
							.foregroundColor(Color(colorEnum: .text))
							.minimumScaleFactor(0.6)

						Text(noDataText.localized)
							.font(.system(size: CGFloat(.normalMediumFontSize)))
							.foregroundColor(Color(colorEnum: .text))
							.minimumScaleFactor(0.5)
					}
			}
		}
	}

    @ViewBuilder
    var secondaryFieldsView: some View {
        VStack(spacing: CGFloat(.defaultSpacing)) {
            PercentageGridLayoutView(firstColumnPercentage: 0.5) {
                ForEach(WeatherField.secondaryFields, id: \.description) { field in
                    weatherFieldView(for: field)
                }
            }

            if let lastUpdatedText {
                HStack {
                    Spacer()
                    Text(lastUpdatedText)
                        .font(.system(size: CGFloat(.caption)))
                        .foregroundColor(Color(colorEnum: .darkGrey))
                }
            }

            if let buttonTitle, let buttonAction {
                Button {
                    buttonAction()
                } label: {
                    Text(buttonTitle)
                }
                .buttonStyle(WXMButtonStyle.solid)
                .buttonStyle(.plain)
                .disabled(!isButtonEnabled)
            }
        }
    }

    @ViewBuilder
    func weatherFieldView(for field: WeatherField) -> some View {
        HStack(spacing: 0.0) {
            Image(asset: field.icon)
                .renderingMode(.template)
                .foregroundColor(Color(colorEnum: .darkestBlue))
				.aspectRatio(contentMode: .fill)
				.rotationEffect(Angle(degrees: field.iconRotation(from: weather)))

            VStack(alignment: .leading, spacing: 0.0) {
                Text(field.description)
					.foregroundColor(Color(colorEnum: .darkestBlue))
					.font(.system(size: weatherFieldsTitleFontSize, weight: .bold))
					.lineLimit(1)
					.minimumScaleFactor(0.8)

                Text(field.attributedString(from: weather,
											unitsManager: unitsManager,
											fontSize: weatherFieldsValueFontSize))
            }
        }
    }

    @ViewBuilder
	var weatherImage: some View {
#if MAIN_APP
		Group {
			if let weather {
				LottieView(animationCase: weather.icon?.getAnimationString() ?? "".getAnimationString(), loopMode: .loop)
			} else {
				LottieView(animationCase: "anim_not_available", loopMode: .loop)
			}
		}
		.frame(width: weatherIconDimensions, height: weatherIconDimensions)
#else
		Image(weather?.icon ?? "")
			.resizable()
			.aspectRatio(contentMode: .fit)
			.frame(width: weatherIconDimensions, height: weatherIconDimensions)
#endif
	}

    var attributedTemperatureString: AttributedString {
        let font = UIFont.systemFont(ofSize: temperatureFontSize)
        let temperatureLiterals: WeatherValueLiterals = WeatherField.temperature.weatherLiterals(from: weather, unitsManager: unitsManager) ?? ("", "")

        var attributedString = AttributedString("\(temperatureLiterals.value)\(temperatureLiterals.unit)")
        attributedString.font = font
        attributedString.foregroundColor = Color(colorEnum: .text)

        if let unitRange = attributedString.range(of: temperatureLiterals.unit) {
            let superScriptFont = UIFont.systemFont(ofSize: temperatureUnitFontSize)
            attributedString[unitRange].foregroundColor = Color(colorEnum: .darkGrey)
            attributedString[unitRange].font = superScriptFont
        }

        return attributedString
    }

    var attributedFeelsLikeString: AttributedString {
        let feelsLikeLiteral = LocalizableString.feelsLike.localized
        let temperatureLiterals: WeatherValueLiterals = WeatherField.feelsLike.weatherLiterals(from: weather, unitsManager: unitsManager) ?? ("", "")

        var attributedString = AttributedString("\(feelsLikeLiteral) \(temperatureLiterals.value)\(temperatureLiterals.unit)")
        attributedString.font = .system(size: CGFloat(.littleCaption))
        attributedString.foregroundColor = Color(colorEnum: .darkestBlue)

        if let temperatureRange = attributedString.range(of: temperatureLiterals.value) {
            attributedString[temperatureRange].font = .system(size: feelsLikeFontSize, weight: .bold)
            attributedString[temperatureRange].foregroundColor = Color(colorEnum: .text)
        }

        if let unitRange = attributedString.range(of: temperatureLiterals.unit) {
            attributedString[unitRange].font = .system(size: feelsLikeUnitFontSize)
            attributedString[unitRange].foregroundColor = Color(colorEnum: .darkGrey)
        }

        return attributedString
    }
}

private extension WeatherOverviewView {
	var weatherFieldsSpacing: CGFloat {
		switch mode {
			case .minimal:
				return 0.0
			case .medium:
				return 0.0
			case .large:
				return CGFloat(.minimumSpacing)
			case .default:
				return CGFloat(.smallSpacing)
		}
	}

	var weatherFieldsTitleFontSize: CGFloat {
		switch mode {
			case .minimal:
				return 0.0
			case .medium:
				return CGFloat(.littleCaption)
			case .large:
				return CGFloat(.caption)
			case .default:
				return CGFloat(.caption)
		}
	}

	var weatherFieldsValueFontSize: CGFloat {
		switch mode {
			case .minimal:
				0.0
			case .medium:
				CGFloat(.caption)
			case .large:
				CGFloat(.normalFontSize)
			case .default:
				CGFloat(.mediumFontSize)
		}
	}

	var temperatureFontSize: CGFloat {
		switch mode {
			case .minimal:
				CGFloat(.largeTitleFontSize)
			case .medium:
				CGFloat(.largeTitleFontSize)
			case .large:
				CGFloat(.largeTitleFontSize)
			case .default:
				CGFloat(.XXXLTitleFontSize)
		}
	}

	var temperatureUnitFontSize: CGFloat {
		switch mode {
			case .minimal:
				CGFloat(.largeTitleFontSize)
			case .medium:
				CGFloat(.largeTitleFontSize)
			case .large:
				CGFloat(.largeTitleFontSize)
			case .default:
				CGFloat(.XLTitleFontSize)
		}
	}

	var feelsLikeFontSize: CGFloat {
		switch mode {
			case .minimal:
				CGFloat(.smallFontSize)
			case .medium:
				CGFloat(.smallFontSize)
			case .large:
				CGFloat(.normalFontSize)
			case .default:
				CGFloat(.mediumFontSize)
		}
	}

	var feelsLikeUnitFontSize: CGFloat {
		switch mode {
			case .minimal:
				CGFloat(.littleCaption)
			case .medium:
				CGFloat(.littleCaption)
			case .large:
				CGFloat(.smallFontSize)
			case .default:
				CGFloat(.caption)
		}
	}

	var noDataTitleFontSize: CGFloat {
		switch mode {
			case .minimal:
				return CGFloat(.mediumFontSize)
			case .medium:
				return CGFloat(.mediumFontSize)
			case .large:
				return CGFloat(.mediumFontSize)
			case .default:
				return CGFloat(.smallTitleFontSize)
		}
	}
}
