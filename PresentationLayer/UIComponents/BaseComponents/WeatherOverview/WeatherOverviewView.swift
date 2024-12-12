//
//  WeatherOverviewView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 6/3/23.
//

import SwiftUI
@preconcurrency import DomainLayer

struct WeatherOverviewView: View {
	var mode: Mode = .default
    let weather: CurrentWeather?
    var showSecondaryFields: Bool = false
    let noDataText: LocalizableString
    var lastUpdatedText: String?
    var buttonTitle: String?
    var isButtonEnabled: Bool = true
    var buttonAction: (() -> Void)?

	let unitsManager: WeatherUnitsManager = .default
	var weatherIconDimensions: CGFloat {
		switch mode {
			case .minimal:
				CGFloat(.weatherIconMinDimension)
			case .medium:
				CGFloat(.weatherIconMediumDimension)
			case .large:
				CGFloat(.weatherIconLargeDimension)
			case .default, .grid:
				CGFloat(.weatherIconDefaultDimension)
		}
	}

    var body: some View {
        VStack(spacing: CGFloat(.defaultSpacing)) {
            Group {
                if weather != nil {
                    weatherDataView
                } else {
                    noDataView
                }
            }
            .WXMCardStyle(backgroundColor: Color(colorEnum: .top),
						  insideHorizontalPadding: CGFloat(.defaultSidePadding),
						  insideVerticalPadding: mainViewVerticalPadding,
						  cornerRadius: CGFloat(.cardCornerRadius))

			if showSecondaryFields {
				secondaryFieldsView
					.WXMCardStyle(backgroundColor: Color(colorEnum: .layer1),
								  insideHorizontalPadding: CGFloat(.defaultSidePadding),
								  insideVerticalPadding: 0.0,
								  cornerRadius: CGFloat(.cardCornerRadius))
					.if(mode == .default) { view in
						view.padding(.bottom)
					}
			}
        }
		.if(showSecondaryFields) { view in
			view
				.background(Color(colorEnum: .layer1))
		}
		.if(mode == .default) { view in
			view
				.cornerRadius(CGFloat(.cardCornerRadius))
		}
    }
}

extension WeatherOverviewView {
	enum Mode {
		/// Widgets
		case minimal
		case medium
		case large
		/// Main app
		case `default`
		case grid
	}

	private var mainViewVerticalPadding: CGFloat {
		switch mode {
			case .minimal:
				CGFloat(.minimumPadding)
			case .medium:
				CGFloat(.minimumPadding)
			case .large:
				CGFloat(.smallSidePadding)
			case .default, .grid:
				CGFloat(.defaultSidePadding)
		}
	}
}

struct WeatherOverviewView_Previews: PreviewProvider {
    static var previews: some View {
        return ZStack {
            Color(.red)
			WeatherOverviewView(weather: CurrentWeather.mockInstance,
								showSecondaryFields: true,
								noDataText: .stationNoDataText,
								buttonTitle: "Button text",
								isButtonEnabled: false) {}
        }
    }
}

#Preview("Grid Layout") {
	return ZStack {
		Color(.red)
		WeatherOverviewView(mode: .grid, weather: CurrentWeather.mockInstance, showSecondaryFields: false, noDataText: .stationUnownedNoDataText) {}
	}
}

#Preview {
	return ZStack {
		Color(.red)
		WeatherOverviewView(mode: .minimal, weather: CurrentWeather.mockInstance, showSecondaryFields: false, noDataText: .stationNoDataText) {}
	}
}

#Preview {
	return ZStack {
		Color(.red)
		WeatherOverviewView(mode: .minimal, weather: nil, showSecondaryFields: false, noDataText: .stationNoDataText) {}
	}
}
