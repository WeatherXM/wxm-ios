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
	case arrowLeft = "arrow-left"
	case arrowsRotate = "arrows-rotate"
	case badgeCheck = "badge-check"
	case barcode
	case barsFilter = "bars-filter"
	case batteryLow = "battery-low"
	case calendar
	case cart = "cart-shopping"
	case chartSimple = "chart-simple"
	case check
	case chevronDown = "chevron-down"
	case chevronRight = "chevron-right"
	case chevronUp = "chevron-up"
	case circleCheck = "circle-check"
	case circleFour = "circle-4"
	case circleOne = "circle-1"
	case circleSmall = "circle-small"
	case circleThree = "circle-3"
	case circleTwo = "circle-2"
	case circleXmark = "circle-xmark"
	case close
	case cog
	case coins
	case cloudShowers = "cloud-showers"
	case dropletDegree = "droplet-degree"
	case envelope
	case externalLink = "arrow-up-right-from-square"
	case eye
	case eyeSlash = "eye-slash"
	case faceSadCry = "face-sad-cry"
	case gauge
	case gear
	case gem
	case heart
	case hexagon
	case hexagonCheck = "hexagon-check"
	case hexagonExclamation = "hexagon-exclamation"
	case hexagonXmark = "hexagon-xmark"
	case home
	case humidity
	case image
	case infoCircle = "info-circle"
	case locationArrow = "location-arrow"
	case locationDot = "location-dot"
	case lock
	case magnifyingGlass = "magnifying-glass"
	case plus = "plus-large"
	case pointUp = "hand-back-point-up"
	case qrcode
	case rotateRight = "rotate-right"
	case share = "share-nodes"
	case sliders
	case sparkles
	case split
	case sun
	case temperatureThreeQuarters = "temperature-three-quarters"
	case threeDots = "ellipsis-vertical"
	case trash
	case triangleExclamation = "triangle-exclamation"
	case umbrella
	case user
	case wallet
	case xmark
}
