//
//  TabTypeEnum.swift
//  PresentationLayer
//
//  Created by Danae Kikue Dimou on 11/5/22.
//

import Foundation
import SwiftUI

enum TabSelectionEnum: CaseIterable, Hashable {
	case homeTab
	case mapTab
	case profileTab
	
	var tabIcon: FontIcon {
		switch self {
			case .homeTab:
				return .house
			case .mapTab:
				return .earth
			case .profileTab:
				return .user
		}
	}

	var tabTitle: String {
		switch self {
			case .homeTab:
				LocalizableString.home.localized
			case .mapTab:
				LocalizableString.explorer.localized
			case .profileTab:
				LocalizableString.profile.localized
		}
	}

	var tabSelected: Color {
		switch self {
			case .homeTab, .mapTab, .profileTab:
				return Color(colorEnum: .wxmPrimary)
		}
	}
	
	var tabNotSelected: Color {
		switch self {
			case .homeTab, .mapTab, .profileTab:
				return Color(colorEnum: .darkGrey)
		}
	}
}
