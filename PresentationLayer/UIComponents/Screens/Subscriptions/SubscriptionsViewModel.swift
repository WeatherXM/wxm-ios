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
	@Published var isSuccess: Bool = false
	@Published var isFailed: Bool = false
	@Published var selectedCard: SubscriptionCardView.Card?
	var canContinue: Bool {
		guard let subscribedProduct else {
			return true
		}

		return subscribedProduct.toSubcriptionViewCard != selectedCard
	}
	var failSuccessObject: FailSuccessStateObject?

	private let useCase: MeUseCaseApi
	private var subscribedProduct: StoreProduct?
	private var products: [StoreProduct] = []

	init(useCase: MeUseCaseApi) {
		self.useCase = useCase
	}

	func refresh() async {
		defer {
			isLoading = false
		}

		do {
			let products: [StoreProduct] = try await useCase.getAvailableSubscriptionProducts()
			self.products = products
			self.subscribedProduct = products.first(where: { $0.isSubscribed })
			self.cards = products.map { $0.toSubcriptionViewCard }
			self.selectedCard = self.subscribedProduct?.toSubcriptionViewCard ?? cards.first
		} catch {
			print(error)
		}
	}

	func continueButtonTapped() {
		guard let selectedCard, let index = cards.firstIndex(of: selectedCard) else {
			return
		}

		let prodcut = products[index]
		Task { @MainActor in
			do {
				try await useCase.subscribeToProduct(prodcut)
				showSuccess()
			} catch let productError as StoreProductError {
				guard productError != .purchaseCancelled else {
					return
				}
				showFail(errorDescription: productError.localizedDescription)
			} catch {
				showFail(errorDescription: error.localizedDescription)
			}
		}
	}
}

private extension SubscriptionsViewModel {
	func showSuccess() {
		let object = FailSuccessStateObject(type: .subscription,
											title: LocalizableString.Subscriptions.premiumSubscriptionUlocked.localized,
											subtitle: LocalizableString.Subscriptions.premiumFeaturesUnlocked.localized.attributedMarkdown,
											cancelTitle: nil,
											retryTitle: LocalizableString.continue.localized,
											contactSupportAction: nil,
											cancelAction: nil,
											retryAction: { Router.shared.pop() })
		failSuccessObject = object
		isSuccess = true
	}

	func showFail(errorDescription: String) {
		let object = FailSuccessStateObject(type: .subscription,
											title: LocalizableString.Subscriptions.purchaseFailed.localized,
											subtitle: LocalizableString.Subscriptions.purchaseFailedDescription(errorDescription).localized.attributedMarkdown,
											cancelTitle: LocalizableString.back.localized,
											retryTitle: LocalizableString.retry.localized,
											contactSupportAction: {
			LinkNavigationHelper().openContactSupport(successFailureEnum: .subscription, email: MainScreenViewModel.shared.userInfo?.email)
		},
											cancelAction: { Router.shared.pop() },
											retryAction: { [weak self] in self?.continueButtonTapped() })
		failSuccessObject = object
		isFailed = true
	}
}

extension SubscriptionsViewModel: HashableViewModel {
	nonisolated func hash(into hasher: inout Hasher) {}
}
