//
//  StationHealthView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 14/10/24.
//

import SwiftUI
import DomainLayer
import Toolkit

struct StationHealthView: View {
	let device: DeviceDetails
	let dataQualityAction: VoidCallback
	let locationAction: VoidCallback

    var body: some View {
		LazyVGrid(columns: [.init(spacing: CGFloat(.mediumSpacing)), .init()]) {
			Button(action: dataQualityAction) {
				HStack(spacing: CGFloat(.smallSpacing)) {
					Spacer()

					Text(FontIcon.chartSimple.rawValue)
						.font(.fontAwesome(font: .FAProSolid, size: CGFloat(.mediumFontSize)))
						.foregroundStyle(Color(colorEnum: device.qodStatusColor))

					Text(device.qodStatusText)
						.font(.system(size: CGFloat(.caption)))
						.foregroundStyle(Color(colorEnum: .text))
						.lineLimit(1)

					Spacer()
				}
				.WXMCardStyle(insideHorizontalPadding: CGFloat(.smallSidePadding),
							  insideVerticalPadding: CGFloat(.mediumSidePadding))
			}

			Button(action: locationAction) {
				HStack(spacing: CGFloat(.smallSpacing)) {
					Spacer()
					
					Text(FontIcon.hexagon.rawValue)
						.font(.fontAwesome(font: .FAPro, size: CGFloat(.mediumFontSize)))
						.foregroundStyle(Color(colorEnum: device.pol?.color ?? .noColor))
						.fixedSize()
					
					Text(device.locationText)
						.font(.system(size: CGFloat(.caption)))
						.foregroundStyle(Color(colorEnum: .text))
						.lineLimit(1)
					
					Spacer()
				}
				.WXMCardStyle(insideHorizontalPadding: CGFloat(.smallSidePadding),
							  insideVerticalPadding: CGFloat(.mediumSidePadding))
			}
		}
    }
}

#Preview {
	StationHealthView(device: .mockDevice, dataQualityAction: {}, locationAction: {})
		.padding()
}
