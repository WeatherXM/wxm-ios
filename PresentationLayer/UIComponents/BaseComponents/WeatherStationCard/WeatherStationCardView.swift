//
//  WeatherStationCardView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 29/9/23.
//

import SwiftUI
import DomainLayer
import Toolkit

struct WeatherStationCardView: View {
	let device: DeviceDetails
	let followState: UserDeviceFollowState?
	var followAction: VoidCallback?

	var body: some View {
		VStack(spacing: 0.0) {
			titleView
				.padding(.horizontal, CGFloat(.defaultSidePadding))
				.padding(.top, CGFloat(.defaultSidePadding))
			
			weatherView
		}
	}
}

private extension WeatherStationCardView {
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

#Preview {
	let device = DeviceDetails.mockDevice
	return ZStack {
		Color.red
		WeatherStationCardView(device: device,
							   followState: UserDeviceFollowState(deviceId: device.id!,
																  relation: .owned))
		.frame(height: 600)
		.background(Color.pink)
	}
}
