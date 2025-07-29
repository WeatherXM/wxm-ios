//
//  TabTypeEnum.swift
//  PresentationLayer
//
//  Created by Danae Kikue Dimou on 11/5/22.
//

import Foundation
import SwiftUI

enum TabSelectionEnum: CaseIterable, Hashable {
	case home
	case myStations
	case explorer
	case profile
	
	var tabIcon: FontIcon {
		switch self {
			case .home:
				return .house
			case .myStations:
				return .rectangleHistory
			case .explorer:
				return .earth
			case .profile:
				return .user
		}
	}

	var tabTitle: String {
		switch self {
			case .home:
				LocalizableString.home.localized
			case .myStations:
				LocalizableString.myStations.localized
			case .explorer:
				LocalizableString.explorer.localized
			case .profile:
				LocalizableString.profile.localized
		}
	}

	var tabSelected: Color {
		switch self {
			case .home, .myStations, .explorer, .profile:
				return Color(colorEnum: .wxmPrimary)
		}
	}
	
	var tabNotSelected: Color {
		switch self {
			case .home, .myStations, .explorer, .profile:
				return Color(colorEnum: .darkGrey)
		}
	}
}
