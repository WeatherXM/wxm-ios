//
//  PublicHexes+.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 26/9/25.
//

import DomainLayer

extension PublicHex {
	var cellCapacityReached: Bool {
		guard let deviceCount, let capacity else {
			return false
		}

		return deviceCount >= capacity
	}
}
