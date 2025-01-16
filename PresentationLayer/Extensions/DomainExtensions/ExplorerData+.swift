//
//  ExplorerData+.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 2/9/24.
//

import Foundation
import DomainLayer
import MapboxMaps

extension ExplorerData: @retroactive Equatable {
	public static func == (lhs: ExplorerData, rhs: ExplorerData) -> Bool {
		lhs.totalDevices == rhs.totalDevices &&
		lhs.polygonPoints == rhs.polygonPoints
	}
}
