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
	typealias IssuesChip = (type: CardWarningType, title: String)

	let device: DeviceDetails
	let issues: IssuesChip?
	var isScrollable: Bool = true
	var addressAction: VoidCallback?
	var warningAction: VoidCallback?
	var statusAction: VoidCallback?

	var body: some View {
		HStack(spacing: CGFloat(.smallSpacing)) {
			warningsChip
			statusChip
			bundleChip
			addressChip

			Spacer()
		}
		.if(isScrollable) { content in
			ScrollView(.horizontal, showsIndicators: false) {
				content
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
						.font(.fontAwesome(font: .FAPro, size: CGFloat(.mediumFontSize)))
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
		if let issues {
			Button {
				warningAction?()
			} label: {

				HStack(spacing: CGFloat(.smallSpacing)) {
					Text(issues.type.fontIcon.rawValue)
						.font(.fontAwesome(font: .FAProSolid, size: CGFloat(.mediumFontSize)))
						.foregroundColor(Color(colorEnum: issues.type.iconColor))

					Text(issues.title)
						.font(.system(size: CGFloat(.caption)))
						.foregroundColor(Color(colorEnum: .text))
						.lineLimit(1)
				}
				.WXMCardStyle(backgroundColor: Color(colorEnum: issues.type.tintColor),
							  insideHorizontalPadding: CGFloat(.smallSidePadding),
							  insideVerticalPadding: CGFloat(.smallSidePadding),
							  cornerRadius: CGFloat(.buttonCornerRadius))
			}
			.allowsHitTesting(warningAction != nil)
		} else {
			EmptyView()
		}
	}

	@ViewBuilder
	var bundleChip: some View {
		HStack(spacing: CGFloat(.smallSpacing)) {

			Image(asset: device.icon)
				.renderingMode(.template)
				.foregroundColor(Color(colorEnum: .text))

			Text(device.bundle?.title ?? "")
				.font(.system(size: CGFloat(.caption)))
				.foregroundColor(Color(colorEnum: .text))
				.lineLimit(1)
		}
		.WXMCardStyle(backgroundColor: Color(colorEnum: .blueTint),
					  insideHorizontalPadding: CGFloat(.smallSidePadding),
					  insideVerticalPadding: CGFloat(.smallSidePadding),
					  cornerRadius: CGFloat(.buttonCornerRadius))
	}
}

#Preview {
	StationChipsView(device: .mockDevice, issues: (.error, "2 issues"))
		.padding()
}
