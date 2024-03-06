//
//  RewardBoostsViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 6/3/24.
//

import Foundation
import DomainLayer

class RewardBoostsViewModel: ObservableObject {
	let boost: BoostCardView.Boost

	init(boost: NetworkDeviceRewardDetailsResponse.BoostReward, date: Date?) {
		self.boost = boost.toBoostViewObject(with: date)
	}
}

extension RewardBoostsViewModel: HashableViewModel {
	func hash(into hasher: inout Hasher) {
		hasher.combine("\(boost.title)-\(boost.reward)-\(boost.date)")
	}
}
