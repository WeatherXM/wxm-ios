//
//  SubscriptionsViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 11/11/25.
//

import Foundation
import DomainLayer

@MainActor
class SubscriptionsViewModel: ObservableObject {
	@Published var cards: [SubscriptionCardView.Card] = []
	@Published var isLoading: Bool = true
	@Published var selectedCard: SubscriptionCardView.Card?
	var canContinue: Bool {
		guard let subscribedProduct else {
			return true
		}

		return subscribedProduct.toSubcriptionViewCard != selectedCard
	}

	private let useCase: MeUseCaseApi
	private var subscribedProduct: StoreProduct?

	init(useCase: MeUseCaseApi) {
		self.useCase = useCase
	}

	func refresh() async {
		defer {
			isLoading = false
		}

		do {
			let products: [StoreProduct] = try await useCase.getSubscriptionProducts()
			print(products)
			self.subscribedProduct = products.first(where: { $0.isSubscribed })
			self.cards = products.map { $0.toSubcriptionViewCard }
			self.selectedCard = self.subscribedProduct?.toSubcriptionViewCard ?? cards.first
		} catch {
			print(error)
		}
	}

	func continueButtonTapped() {

	}
}
