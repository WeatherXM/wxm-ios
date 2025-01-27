//
//  StationWidgetView.swift
//  station-widgetExtension
//
//  Created by Pantelis Giazitsis on 29/9/23.
//

import SwiftUI
import WidgetKit
@preconcurrency import DomainLayer

struct StationWidgetView: View {
	let entry: StationTimelineEntry
	@Environment(\.widgetFamily) var family: WidgetFamily

	var body: some View {
		Group {
			switch entry.timelineCase {
				case .station(let device, let followState):
					stationView(device: device, followState: followState, uiMode: entry.weatherOverViewMode)
				case .loggedOut:
					LoggedOutView()
				case .empty:
					emptyView
				case .error(let info):
					errorView(info: info)
				case .selectStation:
					selectStationView
			}
		}
		.widgetURL(entry.timelineCase.widgetUrl)
	}
}

private extension StationWidgetView {

	@ViewBuilder
	var emptyView: some View {
		WXMEmptyView(configuration: .init(image: nil,
										  enableSidePadding: false,
										  title: LocalizableString.Widget.emptyViewTitle.localized,
										  description: LocalizableString.Widget.emptyViewDescription.localized.attributedMarkdown))
		.padding(.horizontal, CGFloat(.smallSidePadding))
		.widgetBackground {
			Color(colorEnum: .bg)
		}
	}

	@ViewBuilder
	var selectStationView: some View {
		VStack(spacing: CGFloat(.smallSpacing)) {
			Text(FontIcon.pointUp.rawValue)
				.font(.fontAwesome(font: .FAProSolid, size: CGFloat(.XLTitleFontSize)))
				.foregroundColor(Color(colorEnum: .text))

			HStack {
				Spacer()
				Text(LocalizableString.Widget.selectStationDescription.localized)
					.font(.system(size: CGFloat(.mediumFontSize), weight: .bold))
					.foregroundColor(Color(colorEnum: .text))
					.multilineTextAlignment(.center)
					.minimumScaleFactor(0.7)
				Spacer()
			}
		}
		.padding(.vertical, CGFloat(.mediumSidePadding))
		.widgetBackground {
			Color(colorEnum: .bg)
		}
	}

	@ViewBuilder
	func errorView(info: NetworkErrorResponse.UIInfo) -> some View {
		VStack {
			Spacer(minLength: 0.0)

			HStack {
				Spacer(minLength: 0.0)
				ErrorView(errorInfo: info)
				Spacer(minLength: 0.0)
			}

			Spacer(minLength: 0.0)
		}
		.padding(.horizontal, CGFloat(.smallSidePadding))
		.widgetBackground {
			Color(colorEnum: .errorTint)
		}
	}

	@ViewBuilder
	func stationView(device: DeviceDetails, followState: UserDeviceFollowState?, uiMode: WeatherOverviewView.Mode) -> some View {
		switch family {
			case .systemSmall:
				smallView(device: device, followState: followState)
			case .systemMedium:
				mediumView(device: device, followState: followState, uiMode: uiMode)
			case .systemLarge:
				largeView(device: device, followState: followState)
			default:
				EmptyView()
		}
	}

	@ViewBuilder
	func smallView(device: DeviceDetails, followState: UserDeviceFollowState?) -> some View {
		VStack(spacing: 0.0) {

			smalltitleView(device: device, followState: followState)
				.padding(.horizontal, CGFloat(.smallSidePadding))

			Spacer()

			WeatherOverviewView(mode: .minimal, weather: device.weather, noDataText: followState.weatherNoDataText)
		}
		.padding(.vertical, CGFloat(.smallSidePadding))
		.widgetBackground {
			Color(colorEnum: .top)
		}
	}

	@ViewBuilder
	func mediumView(device: DeviceDetails, followState: UserDeviceFollowState?, uiMode: WeatherOverviewView.Mode) -> some View {
		VStack(spacing: 0.0) {
			Spacer(minLength: 0.0)

			titleView(device: device, followState: followState)
				.padding(.horizontal, CGFloat(.mediumSidePadding))

			WeatherOverviewView(mode: uiMode, weather: device.weather, noDataText: followState.weatherNoDataText)

			Spacer(minLength: 0.0)
		}
		.widgetBackground {
			Color(colorEnum: .top)
		}
	}

	@ViewBuilder
	func largeView(device: DeviceDetails, followState: UserDeviceFollowState?) -> some View {
		VStack(spacing: CGFloat(.smallSpacing)) {

			titleView(device: device, followState: followState)
				.padding(.horizontal, CGFloat(.mediumSidePadding))

			WeatherOverviewView(mode: .large, weather: device.weather, showSecondaryFields: true, noDataText: followState.weatherNoDataText)
				.cornerRadius(CGFloat(.cardCornerRadius))

		}
		.widgetBackground {
			VStack {
				Color(colorEnum: .top)
				Color(colorEnum: .layer1)
			}
		}
	}

	@ViewBuilder
	func titleView(device: DeviceDetails,
				   followState: UserDeviceFollowState?) -> some View {
		let titleFontSize = entry.weatherOverViewMode == .minimal ? CGFloat(.caption) : CGFloat(.mediumFontSize)
		VStack(spacing: CGFloat(.minimumSpacing)) {
			HStack(spacing: 0.0) {
				Text(device.displayName)
					.font(.system(size: titleFontSize, weight: .bold))
					.foregroundColor(Color(colorEnum: .text))
					.lineLimit(1)

				Spacer()

				if let faIcon = followState?.state.FAIcon {
					Text(faIcon.icon.rawValue)
						.font(.fontAwesome(font: faIcon.font, size: CGFloat(.normalFontSize)))
						.foregroundColor(Color(colorEnum: faIcon.color))
				}
			}
			.padding(.top, CGFloat(.minimumPadding))

			chipsView(device: device, followState: followState, isSmall: false)
		}
	}

	@ViewBuilder
	func smalltitleView(device: DeviceDetails,
						followState: UserDeviceFollowState?) -> some View {
		VStack(spacing: CGFloat(.minimumSpacing)) {
			HStack(spacing: CGFloat(.minimumSpacing)) {

				chipsView(device: device, followState: followState, isSmall: true)

				Spacer(minLength: 0.0)

				if let faIcon = followState?.state.FAIcon {
					Text(faIcon.icon.rawValue)
						.font(.fontAwesome(font: faIcon.font, size: CGFloat(.normalFontSize)))
						.foregroundColor(Color(colorEnum: faIcon.color))
				}
			}

			HStack(spacing: 0.0) {
				Text(device.displayName)
					.font(.system(size: CGFloat(.normalFontSize), weight: .bold))
					.foregroundColor(Color(colorEnum: .text))

				Spacer(minLength: 0.0)
			}
		}
	}

	@ViewBuilder
	func chipsView(device: DeviceDetails,
				   followState: UserDeviceFollowState?,
				   isSmall: Bool) -> some View {
		HStack(spacing: CGFloat(.minimumSpacing)) {
			HStack(spacing: CGFloat(.minimumSpacing)) {
				Circle()
					.foregroundColor(Color(colorEnum: activeStateColor(isActive: device.isActive)))
					.frame(width: 7.0)

				if let lastActiveAtDate = device.lastActiveAt?.timestampToDate() {
					let style: Text.DateStyle = lastActiveAtDate.isToday ? .time : .date
					Text(lastActiveAtDate, style: style)
						.font(.system(size: CGFloat(.caption)))
						.foregroundColor(Color(colorEnum: .text))
						.lineLimit(1)
						.multilineTextAlignment(.trailing)
						.minimumScaleFactor(0.8)
				}
			}
			.WXMCardStyle(backgroundColor: Color(colorEnum: activeStateTintColor(isActive: device.isActive)),
						  insideHorizontalPadding: CGFloat(.smallSidePadding),
						  insideVerticalPadding: CGFloat(.minimumPadding),
						  cornerRadius: CGFloat(.buttonCornerRadius))

			if !isSmall {
				HStack(spacing: CGFloat(.minimumSpacing)) {
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
							  insideVerticalPadding: CGFloat(.minimumPadding),
							  cornerRadius: CGFloat(.buttonCornerRadius))

				addressView(device: device)
			}

			Spacer(minLength: 0.0)
		}
		.frame(height: 25.0)
	}

	@ViewBuilder
	func addressView(device: DeviceDetails) -> some View {
		if let address = device.address {
			HStack(spacing: CGFloat(.minimumSpacing)) {
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
						  insideVerticalPadding: CGFloat(.minimumPadding),
						  cornerRadius: CGFloat(.buttonCornerRadius))
		}
	}
}

@available(iOSApplicationExtension 17.0, *)
struct StationWidgetView_Preview: PreviewProvider {
	static var previews: some View {
		Group {
			let device = DeviceDetails.widgetPreviewDevice
			StationWidgetView(entry: .init(date: .now,
										   displaySize: CGSize(width: 360.0, height: 170.0),
										   id: device.id,
										   devices: [device],
										   followState: .init(deviceId: device.id!, relation: .followed),
										   errorInfo: nil, // .init(title: "This is an error title",
										   // description: LocalizableString.Error.noInternetAccess.localized),
										   isLoggedIn: true))
			.previewContext(WidgetPreviewContext(family: .systemMedium))
		}
		.containerBackground(for: .widget) {
			Color(colorEnum: .top)
		}
	}
}
