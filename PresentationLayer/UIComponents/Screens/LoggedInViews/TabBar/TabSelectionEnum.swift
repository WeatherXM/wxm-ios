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
	
	var tabIcon: Image {
		switch self {
			case .homeTab:
				return Image(asset: .home)
			case .mapTab:
				return Image(asset: .globe)
			case .profileTab:
				return Image(asset: .user)
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
