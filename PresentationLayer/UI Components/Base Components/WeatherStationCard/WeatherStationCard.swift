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
			WeatherStationCardView(device: device, followState: followState, followAction: followAction)
				.background {
					Color(colorEnum: .top)
						.cornerRadius(CGFloat(.cardCornerRadius))
				}

			statusView
        }
		.background {
			statusContainerBackground
				.cornerRadius(CGFloat(.cardCornerRadius))
		}
        .if(!device.isActive) { view in
            view.strokeBorder(color: Color(colorEnum: .error), lineWidth: 1.0, radius: CGFloat(.cardCornerRadius))
        }
        .if(device.isActive && device.needsUpdate(mainVM: mainScreenViewModel, followState: followState)) { view in
            view.strokeBorder(color: Color(colorEnum: .warning), lineWidth: 1.0, radius: CGFloat(.cardCornerRadius))
        }
        .WXMCardStyle(backgroundColor: Color(colorEnum: .top),
                            insideHorizontalPadding: .zero,
                            insideVerticalPadding: .zero,
                            cornerRadius: CGFloat(.cardCornerRadius))
        .wxmShadow()
    }
}

struct WeatherStationCard_Previews: PreviewProvider {
    static var previews: some View {
        let device = DeviceDetails.mockDevice
        return WeatherStationCard(device: device,
                                  followState: UserDeviceFollowState(deviceId: device.id!, relation: .owned))
    }
}
