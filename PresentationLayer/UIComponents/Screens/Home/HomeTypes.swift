//
//  HomeTypes.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 1/8/25.
//

import DomainLayer

enum CurrentLocationViewState {
	case allowLocation
	case forecast(HomeForecastView.LocationForecast)
	case empty
}
