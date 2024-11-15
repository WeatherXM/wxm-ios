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
	let issues: IssuesChip?
	var isScrollable: Bool = true
	var warningAction: VoidCallback?

	var body: some View {
		HStack(spacing: CGFloat(.smallSpacing)) {
			issuesChip
			statusChip
			bundleChip

			Spacer()
		}
		.if(isScrollable) { content in
			ScrollView(.horizontal, showsIndicators: false) {
				content
			}
		}
	}
}

extension StationChipsView {
	struct IssuesChip {
		let type: CardWarningType
		let icon: FontIcon
		let title: String
	}
}

private extension StationChipsView {
	@ViewBuilder
	var statusChip: some View {
		StationLastActiveView(device: device)
	}

	@ViewBuilder
	var issuesChip: some View {
		if let issues {
			Button {
				warningAction?()
			} label: {

				HStack(spacing: CGFloat(.smallSpacing)) {
					Text(issues.icon.rawValue)
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
	StationChipsView(device: .mockDevice, issues: .init(type: .error,
														icon: .arrowsRotate,
														title: "2 issues"))
		.padding()
}
