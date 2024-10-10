//
//  StationLastActiveView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 3/3/23.
//

import SwiftUI
import DomainLayer

struct StationLastActiveView: View {

    let configuration: Configuration

    var body: some View {
		HStack(spacing: CGFloat(.smallSpacing)) {
			Circle()
                .foregroundColor(Color(colorEnum: configuration.stateColor))
				.frame(width: 10.0)

			Text(configuration.lastActiveAt?.lastActiveTime() ?? LocalizableString.notAvailable.localized)
                .font(.system(size: CGFloat(.caption)))
				.foregroundColor(Color(colorEnum: .text))
        }
		.WXMCardStyle(backgroundColor: Color(colorEnum: .blueTint),
                      insideHorizontalPadding: CGFloat(.smallSidePadding),
                      insideVerticalPadding: CGFloat(.smallSidePadding),
                      cornerRadius: CGFloat(.buttonCornerRadius))
    }
}

extension StationLastActiveView {
    struct Configuration {
        let lastActiveAt: String?
        let stateColor: ColorEnum
    }

    init(device: DeviceDetails) {
        let conf = Configuration(lastActiveAt: device.lastActiveAt,
                                 stateColor: device.isActiveStateColor)
        self.configuration = conf
    }
}

struct StationLastActiveView_Previews: PreviewProvider {
    static var previews: some View {
        var device = DeviceDetails.emptyDeviceDetails
		device.bundle = .mock(name: .h1)
        device.isActive = false
        device.lastActiveAt = Date().ISO8601Format()
        return StationLastActiveView(device: device)
    }
}
