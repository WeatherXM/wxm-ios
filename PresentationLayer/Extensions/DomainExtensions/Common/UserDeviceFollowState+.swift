//
//  UserDeviceFollowState+.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 8/8/23.
//

import DomainLayer

typealias StateFontAwesome = (icon: FontIcon, color: ColorEnum, font: FontAwesome)

extension UserDeviceFollowState {
	nonisolated(unsafe) static let defaultFAIcon: StateFontAwesome = (FontIcon.heart, ColorEnum.favoriteHeart, FontAwesome.FAPro)

    enum State {
        case owned
        case followed

        var FAIcon: StateFontAwesome {
            switch self {
                case .owned:
                    return (FontIcon.home, ColorEnum.text, FontAwesome.FAProSolid)
                case .followed:
                    return (FontIcon.heart, ColorEnum.favoriteHeart, FontAwesome.FAProSolid)
            }
        }

        var isActionable: Bool {
            switch self {
                case .owned:
                    return false
                case .followed:
                    return true
            }
        }
    }

    var state: State {
        return relation == .followed ? .followed : .owned
    }
}

extension UserDeviceFollowState? {
	var weatherNoDataText: LocalizableString {
		switch self?.state {

			case .none:
				return .stationUnownedNoDataText
			case .some(let value):
				switch value {
					case .owned:
						return .stationNoDataText
					case .followed:
						return .stationUnownedNoDataText
				}
		}
	}
}
