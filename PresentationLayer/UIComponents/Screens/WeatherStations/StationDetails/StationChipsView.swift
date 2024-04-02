//
//  StationChipsView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 2/4/24.
//

import SwiftUI
import DomainLayer

struct StationChipsView: View {
	let device: DeviceDetails

    var body: some View {
		ScrollView(.horizontal) {
			HStack(spacing: CGFloat(.smallSpacing)) {
				warningsChip
				statusChip
				addressChip
			}
		}
    }
}

private extension StationChipsView {
	@ViewBuilder
	var addressChip: some View {
		if let address = device.address {
			Button {
//				tapAddressAction?()
			} label: {

				HStack(spacing: CGFloat(.smallSpacing)) {
					Text(FontIcon.hexagon.rawValue)
						.font(.fontAwesome(font: .FAPro, size: CGFloat(.caption)))
						.foregroundColor(Color(colorEnum: .text))

					Text(address)
						.font(.system(size: CGFloat(.caption)))
						.foregroundColor(Color(colorEnum: .text))
						.lineLimit(1)
				}
				.WXMCardStyle(backgroundColor: Color(colorEnum: .blueTint),
							  insideHorizontalPadding: CGFloat(.smallSidePadding),
							  insideVerticalPadding: CGFloat(.smallSidePadding),
							  cornerRadius: CGFloat(.buttonCornerRadius))
			}
		} else {
			EmptyView()
		}
//		.allowsHitTesting(tapAddressAction != nil)
	}

	@ViewBuilder
	var statusChip: some View {
		StationLastActiveView(device: device)
	}

	@ViewBuilder
	var warningsChip: some View {
		Button {
//				tapAddressAction?()
		} label: {

			HStack(spacing: CGFloat(.smallSpacing)) {
				Text(FontIcon.hexagonExclamation.rawValue)
					.font(.fontAwesome(font: .FAProSolid, size: CGFloat(.mediumFontSize)))
					.foregroundColor(Color(colorEnum: .warning))

				Text(verbatim: "warnings")
					.font(.system(size: CGFloat(.caption)))
					.foregroundColor(Color(colorEnum: .text))
					.lineLimit(1)
			}
			.WXMCardStyle(backgroundColor: Color(colorEnum: .warningTint),
						  insideHorizontalPadding: CGFloat(.smallSidePadding),
						  insideVerticalPadding: CGFloat(.smallSidePadding),
						  cornerRadius: CGFloat(.buttonCornerRadius))
		}

	}
}

#Preview {
	StationChipsView(device: .mockDevice)
		.padding()
}
