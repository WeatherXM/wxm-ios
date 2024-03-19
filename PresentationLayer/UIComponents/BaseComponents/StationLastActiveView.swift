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
        HStack(spacing: 0.0) {
            Image(asset: configuration.icon)
                .renderingMode(.template)
                .foregroundColor(Color(colorEnum: configuration.stateColor))

            Text(configuration.lastActiveAt?.lastActiveTime() ?? "-")
                .font(.system(size: CGFloat(.caption)))
                .foregroundColor(Color(colorEnum: configuration.stateColor))
                .padding(.trailing, CGFloat(.smallSidePadding))
        }
        .WXMCardStyle(backgroundColor: Color(colorEnum: configuration.tintColor),
                      insideHorizontalPadding: 0.0,
                      insideVerticalPadding: 0.0,
                      cornerRadius: CGFloat(.buttonCornerRadius))
    }
}

extension StationLastActiveView {
    struct Configuration {
        let lastActiveAt: String?
        let icon: AssetEnum
        let stateColor: ColorEnum
        let tintColor: ColorEnum
    }

    init(device: DeviceDetails) {
        let conf = Configuration(lastActiveAt: device.lastActiveAt,
                                 icon: device.icon,
                                 stateColor: device.isActiveStateColor,
                                 tintColor: device.isActiveStateTintColor)
        self.configuration = conf
    }
}

struct StationLastActiveView_Previews: PreviewProvider {
    static var previews: some View {
        var device = DeviceDetails.emptyDeviceDetails
        device.profile = .helium
        device.isActive = false
        device.lastActiveAt = Date().ISO8601Format()
        return StationLastActiveView(device: device)
    }
}
