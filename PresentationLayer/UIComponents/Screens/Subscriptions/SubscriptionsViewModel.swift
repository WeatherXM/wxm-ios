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
	@Published var subscriptions: [SubscriptionCardView.Card] = []
	@Published var isLoading: Bool = false
	private let useCase: MeUseCaseApi

	init(useCase: MeUseCaseApi) {
		self.useCase = useCase
	}

	func refresh() async {
		do {
			let products: [StoreProduct] = try await useCase.getSubscriptionProducts()
			print(products)
		} catch {
			print(error)
		}

	}
}
