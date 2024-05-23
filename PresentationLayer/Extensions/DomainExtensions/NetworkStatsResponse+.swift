//
//  NetworkStatsResponse+.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 23/5/24.
//

import Foundation
import DomainLayer

extension NetworkStationsStatsTokens {
	var supplyProgress: CGFloat {
		guard let totalSupply, let circulatingSupply else {
			return 0.0
		}

		return CGFloat(circulatingSupply) / CGFloat(totalSupply)
	}
}
