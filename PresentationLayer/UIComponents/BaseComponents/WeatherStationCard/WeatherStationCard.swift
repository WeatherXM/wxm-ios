//
//  WeatherStationCard.swift
//  PresentationLayer
//
//  Created by Pantelis Giazitsis on 26/1/23.
//

import DomainLayer
import SwiftUI
import Toolkit

struct WeatherStationCard: View {
	let device: DeviceDetails
	let followState: UserDeviceFollowState?
	var updateFirmwareAction: VoidCallback = {}
	var viewMoreAction: VoidCallback = {}
	var followAction: VoidCallback?
	let mainScreenViewModel: MainScreenViewModel = .shared

	var body: some View {
		VStack(spacing: 0.0) {
			WeatherStationCardView(device: device,
								   followState: followState,
								   followAction: followAction)

			if UIDevice.current.isIPad {
				Spacer()
			}

			healthMetricsView
		}
		.if(UIDevice.current.isIPad) { view in
			// Modify the view to get equal heights in iPad grid layout
			view.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
		}
		.WXMCardStyle(backgroundColor: Color(colorEnum: .top),
					  insideHorizontalPadding: .zero,
					  insideVerticalPadding: .zero,
					  cornerRadius: CGFloat(.cardCornerRadius))
		.stationIndication(device: device, followState: followState)
		.wxmShadow()
	}
}

private extension WeatherStationCard {
	@ViewBuilder
	var healthMetricsView: some View {
		HStack(spacing: CGFloat(.mediumSpacing)) {
			HStack(spacing: CGFloat(.smallSpacing)) {
				Text(FontIcon.chartSimple.rawValue)
					.font(.fontAwesome(font: .FAProSolid, size: CGFloat(.mediumFontSize)))
					.foregroundStyle(Color(colorEnum: device.qodStatusColor))
					.fixedSize()

				Text(device.qodStatusText)
					.font(.system(size: CGFloat(.caption)))
					.foregroundStyle(Color(colorEnum: .text))
					.fixedSize()
			}

			HStack(spacing: CGFloat(.smallSpacing)) {
				Text(FontIcon.hexagon.rawValue)
					.font(.fontAwesome(font: .FAPro, size: CGFloat(.mediumFontSize)))
					.foregroundStyle(Color(colorEnum: device.pol?.color ?? .noColor))
					.fixedSize()

				Text(device.locationText)
					.font(.system(size: CGFloat(.caption)))
					.foregroundStyle(Color(colorEnum: .text))
					.lineLimit(2)
					.fixedSize(horizontal: false, vertical: true)
			}

			Spacer()
		}
		.padding(.horizontal, CGFloat(.defaultSpacing))
		.padding(.vertical, CGFloat(.smallToMediumSpacing))
		.background(Color(colorEnum: .blueTint))
	}
}

struct WeatherStationCard_Previews: PreviewProvider {
	static var previews: some View {
		let device = DeviceDetails.mockDevice
		return WeatherStationCard(device: device,
								  followState: UserDeviceFollowState(deviceId: device.id!, relation: .owned))
	}
}
