//
//  ShadowEnum.swift
//  PresentationLayer
//
//  Created by Hristos Condrea on 13/5/22.
//

import Foundation

enum ShadowEnum {
	case tabBar
	case baseButton

	case deviceIcon
	case addButton
	case stationCard

	var radius: Double {
		switch self {
			case .deviceIcon:
				return 1
			case .tabBar:
				return 5
			case .baseButton, .addButton:
				return 2
			case .stationCard:
				return 4.0
		}
	}

	var xVal: Double {
		switch self {
			case .tabBar, .baseButton, .addButton, .stationCard:
				return 0
			case .deviceIcon:
				return 1
		}
	}

	var yVal: Double {
		switch self {
			case .baseButton, .deviceIcon:
				return 1
			case .tabBar, .stationCard:
				return 4
			case .addButton:
				return 5
		}
	}
}
