//
//  WeatherOverviewView+Content.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 6/3/23.
//

import SwiftUI
@preconcurrency import DomainLayer

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
				case .grid:
					PercentageGridLayoutView(alignments: [.leading, .leading], firstColumnPercentage: 0.25) {
						Group {
							weatherImage

							LazyVGrid(columns: [.init(), .init()],
									  spacing: CGFloat(.mediumSpacing)) {
								ForEach(WeatherField.stationListFields, id: \.description) { field in
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
				case .default, .medium, .large, .grid:
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
			PercentageGridLayoutView(firstColumnPercentage: 0.5,
									 linesSpacing: CGFloat(.smallSpacing)) {
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
		HStack(alignment: .center, spacing: CGFloat(.smallSpacing)) {
			Text(field.fontIcon?.rawValue ?? "")
				.font(.fontAwesome(font: .FAProSolid, size: CGFloat(.smallTitleFontSize)))
				.foregroundColor(Color(colorEnum: .darkestBlue))
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

			Spacer(minLength: 0.0)
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
		/// Different configuration according to the `Mode`. `.default` mode is when is presented in the main app, otherwise is widget
		let weight: UIFont.Weight = mode == .default ? .regular : .bold
		let font = UIFont.systemFont(ofSize: temperatureFontSize, weight: weight)
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
			case .grid:
				return CGFloat(.mediumSpacing)
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
			case .default, .grid:
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
			case .default, .grid:
				CGFloat(.mediumFontSize)
		}
	}

	var temperatureFontSize: CGFloat {
		switch mode {
			case .minimal:
				CGFloat(.smallTitleFontSize)
			case .medium:
				CGFloat(.largeTitleFontSize)
			case .large:
				CGFloat(.largeTitleFontSize)
			case .default:
				CGFloat(.XXXLTitleFontSize)
			case .grid:
				// There is no special position for the temperature in this layout
				0.0
		}
	}

	var temperatureUnitFontSize: CGFloat {
		switch mode {
			case .minimal:
				CGFloat(.caption)
			case .medium:
				CGFloat(.largeTitleFontSize)
			case .large:
				CGFloat(.largeTitleFontSize)
			case .default:
				CGFloat(.XLTitleFontSize)
			case .grid:
				// There is no special position for the temperature in this layout
				0.0
		}
	}

	var feelsLikeFontSize: CGFloat {
		switch mode {
			case .minimal:
				CGFloat(.mediumFontSize)
			case .medium:
				CGFloat(.smallFontSize)
			case .large:
				CGFloat(.normalFontSize)
			case .default:
				CGFloat(.mediumFontSize)
			case .grid:
				// There is no special position for the temperature in this layout
				0.0
		}
	}

	var feelsLikeUnitFontSize: CGFloat {
		switch mode {
			case .minimal:
				CGFloat(.caption)
			case .medium:
				CGFloat(.littleCaption)
			case .large:
				CGFloat(.smallFontSize)
			case .default:
				CGFloat(.caption)
			case .grid:
				// There is no special position for the temperature in this layout
				0.0
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
			case .default, .grid:
				return CGFloat(.smallTitleFontSize)
		}
	}
}
