//
//  WidgetConstants.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 9/10/23.
//

import Foundation

let widgetScheme = "weatherxmwidget"

enum WidgetUrlType: String {
	case station
	case loggedOut = "logged_out"
	case empty
	case error
	case selectStation = "select_station"
}
