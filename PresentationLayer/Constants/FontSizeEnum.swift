//
//  FontSizeEnum.swift
//  PresentationLayer
//
//  Created by Danae Kikue Dimou on 11/5/22.
//

import SwiftUI

enum FontSizeEnum: CaseIterable {
	case caption
	case smallFontSize
	case normalFontSize
	case normalMediumFontSize
	case mediumFontSize
	case largeFontSize
	case smallTitleFontSize
	case titleFontSize
	case largeTitleFontSize
	case littleCaption
	case XLTitleFontSize
	case XXLTitleFontSize
	case XXXLTitleFontSize
	case maxFontSize

	var sizeValue: CGFloat {
		switch self {
			case .littleCaption:
				return 11
			case .caption:
				return 12
			case .smallFontSize:
				return 13
			case .normalFontSize:
				return 14
			case .normalMediumFontSize:
				return 15
			case .mediumFontSize:
				return 16
			case .largeFontSize:
				return 18
			case .smallTitleFontSize:
				return 20
			case .titleFontSize:
				return 22
			case .largeTitleFontSize:
				return 24
			case .XLTitleFontSize:
				return 28
			case .XXLTitleFontSize:
				return 32
			case .XXXLTitleFontSize:
				return 50.0
			case .maxFontSize:
				return 64.0
		}
	}
}
