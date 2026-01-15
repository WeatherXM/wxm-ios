//
//  SubscriptionsViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 11/11/25.
//

import Foundation
import DomainLayer
import Toolkit

@MainActor
class SubscriptionsViewModel: ObservableObject {
	@Published var plans: [[SubscriptionPlanView.Plan]] = []
	@Published var isLoading: Bool = true
	@Published var isSuccess: Bool = false
	@Published var isFailed: Bool = false
    @Published var currentTabIndex: Int = 0
    @Published var segments: [String] = []
	@Published var selectedPlan: SubscriptionPlanView.Plan?
	var isCTAEnabled: Bool {
        products.contains(where: { $0.identifier == selectedPlan?.productId })
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

            let periods = products.compactMap { $0.period?.unit?.tabTitle }
            self.segments = periods

            let sortedProducts = products.sorted(by: { ($0.period?.unit ?? .day) < ($1.period?.unit ?? .day)})
			self.plans = sortedProducts.map { [generateFreePlan(), $0.toSubscriptionPlan] }
            self.selectedPlan = self.subscribedProduct?.toSubscriptionPlan ?? plans.first?.first
		} catch {
			print(error)
			showFail(errorDescription: error.localizedDescription)
		}
	}

	func continueButtonTapped() {
        guard let selectedPlan, let product = products.first(where: { $0.identifier == selectedPlan.productId }) else {
			return
		}

		Task { @MainActor in
			do {
				try await useCase.subscribeToProduct(product)

				showSuccess()

				WXMAnalytics.shared.trackEvent(.viewContent, parameters: [.contentName: .billingFlowResult,
																		  .success: .custom("\(0)")])
			} catch let productError as StoreProductError {
				let successState: Int = productError == .purchaseCancelled ? 0 : -1
				WXMAnalytics.shared.trackEvent(.viewContent, parameters: [.contentName: .billingFlowResult,
																		  .success: .custom("\(successState)")])

				if productError != .purchaseCancelled {
					showFail(errorDescription: productError.localizedDescription)
				}
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

    func generateFreePlan() -> SubscriptionPlanView.Plan {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = .current
        let price = currencyFormatter.string(from: 0 as NSNumber)
        return .init(fontIcon: .check,
                     title: LocalizableString.Subscriptions.free.localized,
                     isCurrent: subscribedProduct == nil,
                     price: price ?? "-",
                     period: nil,
                     description: nil,
                     bullets: [LocalizableString.Subscriptions.freeSubscriptionBullet0.localized,
                               LocalizableString.Subscriptions.freeSubscriptionBullet1.localized,
                               LocalizableString.Subscriptions.freeSubscriptionBullet2.localized,
                               LocalizableString.Subscriptions.freeSubscriptionBullet3.localized],
                     productId: nil)
    }
}

extension SubscriptionsViewModel: HashableViewModel {
	nonisolated func hash(into hasher: inout Hasher) {}
}
