//
//  NetworkStatsResponse+.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 23/5/24.
//

import Foundation
import DomainLayer

extension NetworkStatsToken {
	var supplyProgress: CGFloat? {
		guard let totalSupply, let circulatingSupply else {
			return nil
		}

		return CGFloat(circulatingSupply) / CGFloat(totalSupply)
	}
}
