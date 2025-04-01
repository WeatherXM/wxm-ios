//
//  NetworkUserRewardsResponse.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 30/11/23.
//

import Foundation

public struct NetworkUserRewardsResponse: Codable, Sendable {
	public let proof: [String]?
	public let cumulativeAmount: String?
	public let cycle: Int?
	public let available: String?
	public let totalClaimed: String?

	enum CodingKeys: String, CodingKey {
		case proof
		case cumulativeAmount = "cumulative_amount"
		case cycle
		case available
		case totalClaimed = "total_claimed"
	}

	public init(proof: [String]?, cumulativeAmount: String?, cycle: Int?, available: String?, totalClaimed: String?) {
		self.proof = proof
		self.cumulativeAmount = cumulativeAmount
		self.cycle = cycle
		self.available = available
		self.totalClaimed = totalClaimed
	}
}
