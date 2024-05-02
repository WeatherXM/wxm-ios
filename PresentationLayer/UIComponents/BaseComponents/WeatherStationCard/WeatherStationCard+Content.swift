//
//  WeatherStationCard+Content.swift
//  PresentationLayer
//
//  Created by Pantelis Giazitsis on 30/1/23.
//

import DomainLayer
import SwiftUI
import Toolkit

/// Main ViewBuilders to be used from body callback
extension WeatherStationCard {
    @ViewBuilder
    var titleView: some View {
        StationAddressTitleView(device: device,
                                followState: followState,
								issues: nil,
                                showSubtitle: false,
                                showStateIcon: true,
                                tapStateIconAction: followAction,
                                tapAddressAction: nil)
    }

    @ViewBuilder
    var weatherView: some View {
        WeatherOverviewView(weather: device.weather)
    }
}

/// Viewbuilders and stuff used internally from the main Viewbuilders
private extension WeatherStationCard {
    @ViewBuilder
    var lastActiveView: some View {
        StationLastActiveView(configuration: device.stationLastActiveConf)
    }
}
