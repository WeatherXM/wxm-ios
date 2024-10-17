//
//  StationIndication.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 22/2/24.
//

import SwiftUI
import DomainLayer
import Toolkit

private struct StationIndicationModifier: ViewModifier {
	let device: DeviceDetails
	let followState: UserDeviceFollowState?
	let mainScreenViewModel = MainScreenViewModel.shared

	func body(content: Content) -> some View {
		let warningType = device.overallWarningType(mainVM: mainScreenViewModel, followState: followState)
		content
			.indication(show: .constant(warningType != nil),
						borderColor: Color(colorEnum: warningType?.iconColor ?? .noColor),
						bgColor: Color(colorEnum: warningType?.tintColor ?? .noColor)) {
				EmptyView()
			}
	}
}


extension View {
	@ViewBuilder
	func stationIndication(device: DeviceDetails, followState: UserDeviceFollowState?) -> some View {
		modifier(StationIndicationModifier(device: device, followState: followState))
	}
}

#Preview {
	VStack {
		HStack {
			Spacer()
			Text(verbatim: "Station")
			Spacer()
		}
	}
	.WXMCardStyle()
	.stationIndication(device: .mockDevice, followState: nil)
	.wxmShadow()
	.padding()
}
