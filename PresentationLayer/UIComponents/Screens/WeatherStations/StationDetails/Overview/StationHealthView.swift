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
				pillView(title: LocalizableString.StationDetails.dataQualityScore.localized,
						 statusIcon: (FontIcon.chartSimple, .fontAwesome(font: .FAProSolid, size: CGFloat(.mediumFontSize))),
						 statusText: qodStatusText,
						 statusColor: device.qodStatusColor)
			}

			Button(action: locationAction) {
				pillView(title: device.locationText,
						 statusIcon: (FontIcon.hexagon, .fontAwesome(font: .FAPro, size: CGFloat(.mediumFontSize))),
						 statusText: polStatusText,
						 statusColor: device.polStatusColor)
			}
		}
    }
}

private extension StationHealthView {
	@ViewBuilder
	func pillView(title: String,
				  statusIcon: (icon: FontIcon, font: Font),
				  statusText: AttributedString,
				  statusColor: ColorEnum) -> some View {
		VStack(spacing: CGFloat(.smallSpacing)) {
			HStack {
				Text(title)
					.font(.system(size: CGFloat(.caption), weight: .bold))
					.foregroundStyle(Color(colorEnum: .darkestBlue))
					.multilineTextAlignment(.leading)
					.lineLimit(1)

				Spacer()
			}

			HStack(spacing: CGFloat(.smallSpacing)) {
				Text(statusIcon.icon.rawValue)
					.font(statusIcon.font)
					.foregroundStyle(Color(colorEnum: statusColor))
					.fixedSize()

				Text(statusText)
					.multilineTextAlignment(.leading)

				Spacer()
			}
			.frame(maxWidth: .infinity, maxHeight: .infinity)
		}
		.WXMCardStyle(backgroundColor: .blueTint,
					  insideHorizontalPadding: CGFloat(.mediumSidePadding),
					  insideVerticalPadding: CGFloat(.mediumSidePadding))

	}

	var qodStatusText: AttributedString {
		guard let qod = device.qod else {
			return LocalizableString.Error.noDataTitle.localized.attributedMarkdown ?? ""
		}

		let percentSymbol = "%"
		var attributedString = AttributedString("\(qod)\(percentSymbol)")
		attributedString.font = .systemFont(ofSize: CGFloat(.mediumFontSize), weight: .bold)
		attributedString.foregroundColor = Color(colorEnum: .text)

		if let percentSymbolRange = attributedString.range(of: percentSymbol) {
			attributedString[percentSymbolRange].font = .system(size: CGFloat(.caption))
			attributedString[percentSymbolRange].foregroundColor = Color(colorEnum: .darkGrey)
		}


		return attributedString
	}

	var polStatusText: AttributedString {
		var attributedString = AttributedString("\(device.polStatusText)")
		attributedString.font = .systemFont(ofSize: CGFloat(.normalFontSize), weight: .bold)
		attributedString.foregroundColor = Color(colorEnum: .text)
		return attributedString
	}
}

#Preview {
	StationHealthView(device: .mockDevice, dataQualityAction: {}, locationAction: {})
		.padding()
}
