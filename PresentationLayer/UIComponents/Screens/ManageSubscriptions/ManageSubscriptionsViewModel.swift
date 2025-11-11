//
//  ManageSubscriptionsViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 10/11/25.
//

import Foundation

@MainActor
class ManageSubscriptionsViewModel: ObservableObject {
	@Published var isSubscribed: Bool = false
	
	func handleGetPremiumTap() {
		let viewModel = ViewModelsFactory.getSubscriptionsViewModel()
		Router.shared.navigateTo(.subscriptions(viewModel))
	}
}

extension ManageSubscriptionsViewModel: HashableViewModel {
	nonisolated func hash(into hasher: inout Hasher) { }
}
