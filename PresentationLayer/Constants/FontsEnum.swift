//
//  FontsEnum.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 22/6/23.
//

import SwiftUI

enum FontAwesome: String {
    case FAPro = "FontAwesome6Pro-Regular"
    case FAProLight = "FontAwesome6Pro-Light"
    case FAProSolid = "FontAwesome6Pro-Solid"
    case FAProThin = "FontAwesome6Pro-Thin"
    case FADuotone = "FontAwesome6Duotone-Solid"
    case FASharp = "FontAwesome6Sharp-Regular"
    case FASharpSolid = "FontAwesome6Sharp-Solid"
    case FABrands = "FontAwesome6Brands-Regular"
}

extension Font {
    static func fontAwesome(font: FontAwesome, size: CGFloat) -> Font {
        return .custom(font.rawValue, size: size)
    }
}

enum FontIcon: String {
    case locationDot = "location-dot"
    case gear
    case threeDots = "ellipsis-vertical"
    case infoCircle = "info-circle"
    case externalLink = "arrow-up-right-from-square"
    case home = "home"
    case hexagon
	case hexagonCheck = "hexagon-check"
	case hexagonExclamation = "hexagon-exclamation"
	case hexagonXmark = "hexagon-xmark"
    case share = "share-nodes"
    case heart
    case lock
    case calendar
    case sliders
	case barsFilter = "bars-filter"
	case pointUp = "hand-back-point-up"
	case badgeCheck = "badge-check"
	case triangleExclamation = "triangle-exclamation"
	case cog
	case coins
	case wallet
	case cart = "cart-shopping"
	case circleOne = "circle-1"
	case circleTwo = "circle-2"
	case circleThree = "circle-3"
	case circleFour = "circle-4"
	case circleSmall = "circle-small"
	case qrcode
	case barcode
	case split
	case close
	case chevronRight = "chevron-right"
	case chevronUp = "chevron-up"
	case chevronDown = "chevron-down"
	case faceSadCry = "face-sad-cry"
	case rotateRight = "rotate-right"
	case temperatureThreeQuarters = "temperature-three-quarters"
	case umbrella
	case cloudShowers = "cloud-showers"
	case locationArrow = "location-arrow"
	case humidity
	case gauge
	case sun
	case dropletDegree = "droplet-degree"
	case arrowsRotate = "arrows-rotate"
	case batteryLow = "battery-low"
	case chartSimple = "chart-simple"
	case eye
	case eyeSlash = "eye-slash"
	case envelope
	case user
}
