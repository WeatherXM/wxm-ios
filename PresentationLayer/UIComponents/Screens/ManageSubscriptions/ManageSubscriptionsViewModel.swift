//
//  ManageSubscriptionsViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 10/11/25.
//

import Foundation
import DomainLayer

@MainActor
class ManageSubscriptionsViewModel: ObservableObject {
	@Published var isLoading: Bool = false
	@Published var products: [StoreProduct] = []
	var isSubscribed: Bool {
		!products.isEmpty
	}

	private let useCase: MeUseCaseApi

	init(useCase: MeUseCaseApi) {
		self.useCase = useCase
	}

	func refresh() async {
		defer {
			isLoading = false
		}

		do {
			let products = try await useCase.getSubscribedProducts()
			self.products = products
		} catch {
			print(error)
			if let message = LocalizableString.Error.genericMessage.localized.attributedMarkdown {
				Toast.shared.show(text: message)
			}
		}
	}

	func handleGetPremiumTap() {
		let viewModel = ViewModelsFactory.getSubscriptionsViewModel()
		Router.shared.navigateTo(.subscriptions(viewModel))
	}
}

private extension ManageSubscriptionsViewModel {
}

extension ManageSubscriptionsViewModel: HashableViewModel {
	nonisolated func hash(into hasher: inout Hasher) { }
}
