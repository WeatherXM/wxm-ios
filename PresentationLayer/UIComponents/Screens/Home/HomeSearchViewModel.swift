//
//  HomeSearchViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 4/8/25.
//

import Foundation
import DomainLayer

class HomeSearchViewModel: ExplorerSearchViewModel {

	override var searhExclude: SearchExclude? {
		.stations
	}
}
