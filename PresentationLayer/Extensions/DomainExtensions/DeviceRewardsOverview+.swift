//
//  DeviceRewardsOverview+.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 27/10/23.
//

import Foundation
import DomainLayer
import Toolkit

extension RewardAnnotation: @retroactive Identifiable {
	public var id: Int {
		hashValue
	}
}

extension RewardAnnotation.Severity: @retroactive Comparable {
	public static func < (lhs: RewardAnnotation.Severity, rhs: RewardAnnotation.Severity) -> Bool {
		lhs.sortOrder < rhs.sortOrder
	}

	private var sortOrder: Int {
		switch self {
			case .info:
				2
			case .warning:
				1
			case .error:
				0
		}
	}

	var toCardWarningType: CardWarningType {
		switch self {
			case .info:
				CardWarningType.info
			case .warning:
				CardWarningType.warning
			case .error:
				CardWarningType.error
		}
	}
}
