//
//  StationChipsView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 2/4/24.
//

import SwiftUI
import DomainLayer
import Toolkit

struct StationChipsView: View {
	let device: DeviceDetails
	let warning: String?
	var addressAction: VoidCallback?
	var warningAction: VoidCallback?
	var statusAction: VoidCallback?

    var body: some View {
		ScrollView(.horizontal, showsIndicators: false) {
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
				addressAction?()
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
			.allowsHitTesting(addressAction != nil)
		} else {
			EmptyView()
		}
	}

	@ViewBuilder
	var statusChip: some View {
		Button {
			statusAction?()
		} label: {
			StationLastActiveView(device: device)
		}
		.allowsHitTesting(statusAction != nil)

	}

	@ViewBuilder
	var warningsChip: some View {
		if let warning {
			Button {
				warningAction?()
			} label: {

				HStack(spacing: CGFloat(.smallSpacing)) {
					Text(FontIcon.hexagonExclamation.rawValue)
						.font(.fontAwesome(font: .FAProSolid, size: CGFloat(.mediumFontSize)))
						.foregroundColor(Color(colorEnum: .warning))

					Text(warning)
						.font(.system(size: CGFloat(.caption)))
						.foregroundColor(Color(colorEnum: .text))
						.lineLimit(1)
				}
				.WXMCardStyle(backgroundColor: Color(colorEnum: .warningTint),
							  insideHorizontalPadding: CGFloat(.smallSidePadding),
							  insideVerticalPadding: CGFloat(.smallSidePadding),
							  cornerRadius: CGFloat(.buttonCornerRadius))
			}
			.allowsHitTesting(warningAction != nil)
		} else {
			EmptyView()
		}
	}
}

#Preview {
	StationChipsView(device: .mockDevice, warning: "Issues text")
		.padding()
}
