//
//  LocalizableString+Widget.swift
//  station-widgetExtension
//
//  Created by Pantelis Giazitsis on 2/10/23.
//

import Foundation

extension LocalizableString {
	enum Widget {
		case loggedOutTitle
		case loggedOutDescription
		case emptyViewTitle
		case emptyViewDescription
		case widgetTitle
		case widgetDescription
		case selectStationDescription
		case previewStationName
		case previewStationAddress
	}
}

extension LocalizableString.Widget: WXMLocalizable {
	var localized: String {
		NSLocalizedString(key, comment: "")
	}

	var key: String {
		switch self {
			case .loggedOutTitle:
				"widget_logged_out_title"
			case .loggedOutDescription:
				"widget_logged_out_description"
			case .emptyViewTitle:
				"widget_empty_view_title"
			case .emptyViewDescription:
				"widget_empty_view_description"
			case .widgetTitle:
				"widget_widget_title"
			case .widgetDescription:
				"widget_widget_description"
			case .selectStationDescription:
				"widget_select_station_description"
			case .previewStationName:
				"widget_preview_station_name"
			case .previewStationAddress:
				"widget_preview_station_address"
		}
	}
}
