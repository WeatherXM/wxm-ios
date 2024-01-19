//
//  ThemeEnum.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 4/4/23.
//

import Foundation
import SwiftUI
import Toolkit

enum Theme: String, CaseIterable, CustomStringConvertible {
    case light
    case dark
    case system

    var description: String {
        switch self {
            case .light:
                return LocalizableString.light.localized
            case .dark:
                return LocalizableString.dark.localized
            case .system:
                return LocalizableString.system.localized
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
            case .light:
                return .light
            case .dark:
                return .dark
            case .system:
                return nil
        }
    }

    var analyticsValue: ParameterValue {
        switch self {
            case .light:
                return .light
            case .dark:
                return .dark
            case .system:
                return .system
        }
    }

    var  interfaceStyle: UIUserInterfaceStyle {
        switch self {
            case .light:
                return .light
            case .dark:
                return .dark
            case .system:
                return .unspecified
        }
    }

    init?(description: String) {
        guard let theme = Self.allCases.first(where: { $0.description == description }) else {
            return nil
        }

        self = theme
    }

	init?(interfaceStyle: UIUserInterfaceStyle) {
		switch interfaceStyle {
			case .unspecified:
				return nil
			case .light:
				self = .light
			case .dark:
				self = .dark
			@unknown default:
				return nil
		}
	}
}
