//
//  Dimensions.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 25/4/23.
//

import Foundation

enum Dimension {
	case minimumPadding
	case smallSidePadding
	case smallToMediumSidePadding
	case mediumSidePadding
	case defaultSidePadding
	case mediumToLargeSidePadding
	case largeSidePadding
	case XLSidePadding
	
	case minimumSpacing
	case smallSpacing
	case smallToMediumSpacing
	case mediumSpacing
	case defaultSpacing
	case largeSpacing
	case XLSpacing

	case lightCornerRadius
	case cardCornerRadius
	case buttonCornerRadius
	case tabBarCornerRadius
	case fabButtonsDimension

	case weatherIconMinDimension
	case weatherIconMediumDimension
	case weatherIconLargeDimension
	case weatherIconDefaultDimension
}

extension Dimension {
	var value: CGFloat {
		switch self {
			case .minimumPadding:
				return 4.0
			case .smallSidePadding:
				return 8.0
			case .smallToMediumSidePadding:
				return 12.0
			case .mediumSidePadding:
				return 16.0
			case .defaultSidePadding:
				return 20.0
			case .mediumToLargeSidePadding:
				return 24.0
			case .largeSidePadding:
				return 30.0
			case .XLSidePadding:
				return 40.0

			case .minimumSpacing:
				return 4.0
			case .smallSpacing:
				return 8.0
			case .smallToMediumSpacing:
				return 12.0
			case .mediumSpacing:
				return 16.0
			case .defaultSpacing:
				return 20.0
			case .largeSpacing:
				return 30.0
			case .XLSpacing:
				return 40.0
			
			case .lightCornerRadius:
				return 4.0
			case .cardCornerRadius:
				return 20.0
			case .buttonCornerRadius:
				return 10.0
			case .tabBarCornerRadius:
				return 60.0
			case .fabButtonsDimension:
				return 60.0

			case .weatherIconMinDimension:
				return 35.0
			case .weatherIconMediumDimension:
				return 45.0
			case .weatherIconLargeDimension:
				return 60.0
			case .weatherIconDefaultDimension:
				return 70.0
		}
	}
}
