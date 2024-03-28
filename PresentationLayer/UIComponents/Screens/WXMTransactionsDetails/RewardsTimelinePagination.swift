//
//  RewardsTimelinePagination.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 9/11/23.
//

import Foundation
import DomainLayer
import Toolkit

struct RewardsTimelinePagination {
	private static let FETCH_INTERVAL_MONTHS = 3

	let	device: DeviceDetails
	let rewardsTimelineObject: NetworkDeviceRewardsTimelineResponse?
	let currentPage: Int
	var fromDate: String = Date.now.getFormattedDateOffsetByMonths(-Self.FETCH_INTERVAL_MONTHS)
	var toDate: String = Date.now.getFormattedDateOffsetByMonths(0)
	
	/// Returns the params for the next page request
	/// - Returns: Tuple with the essentials
	func getNextPagination() -> (page: Int, fromDate: String, toDate: String)? {
		guard let rewardsTimelineObject else {
			return (currentPage, fromDate, toDate)
		}
		
		let hasNextPage = rewardsTimelineObject.hasNextPage ?? false
		if !hasNextPage {
			return nil
		}

		let page = currentPage + 1

		return (page, fromDate, toDate)
	}
}
