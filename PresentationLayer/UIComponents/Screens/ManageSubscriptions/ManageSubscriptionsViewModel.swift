//
//  ManageSubscriptionsViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 10/11/25.
//

import Foundation
import DomainLayer
import Combine

@MainActor
class ManageSubscriptionsViewModel: ObservableObject {
	@Published var isLoading: Bool = false
	@Published var products: [StoreProduct] = []
	var state: ManageSubscriptionsView.State {
		if products.isEmpty {
			return .standard
		}

		if products.contains(where: { $0.isCanceled }) {
			return .canceled
		}

		return .subscribed
	}

	private let useCase: MeUseCaseApi
	private var cacncellables: Set<AnyCancellable> = .init()

	init(useCase: MeUseCaseApi) {
		self.useCase = useCase
		observeTransactionChanges()
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

	func handleCancelSubscriptionTap() {
		LinkNavigationHelper().openUrl(DisplayedLinks.appStoreSubscriptions.linkURL)
	}
}

private extension ManageSubscriptionsViewModel {
	func observeTransactionChanges() {
		useCase.transactionProductsPublisher?.receive(on: DispatchQueue.main).sink { [weak self] _ in
			Task { @MainActor in
				await self?.refresh()
			}
		}.store(in: &cacncellables)
	}
}

extension ManageSubscriptionsViewModel: HashableViewModel {
	nonisolated func hash(into hasher: inout Hasher) { }
}
