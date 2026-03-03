//
//  SubscriptionsViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 11/11/25.
//

import Foundation
import DomainLayer
import Toolkit
import UIKit
import StoreKit
import Combine

@MainActor
class SubscriptionsViewModel: ObservableObject {
    @Published var viewState: SubscriptionsView.State = .free([[]])
	@Published var isLoading: Bool = true
	@Published var isSuccess: Bool = false
	@Published var isFailed: Bool = false
    @Published var currentTabIndex: Int = 0
    @Published var segments: [String] = []
	@Published var selectedPlan: SubscriptionPlanView.Plan?
    @Published var showDowngradeAlert: Bool = false
    var downgradeAlertConfiguration: WXMAlertConfiguration?
	var isCTAEnabled: Bool {
        switch viewState {
            case .free(_):
                return products.contains(where: { $0.identifier == selectedPlan?.productId })
            case .premium(_):
                let isFreeSelected = selectedPlan?.productId == nil
                return isFreeSelected
        }
	}
    var ctaText: String {
        switch viewState {
            case .free(_):
                return LocalizableString.Subscriptions.upgradeToPremium.localized
            case .premium(_):
                let isFreeSelected = selectedPlan?.productId == nil
                if  isFreeSelected {
                    return LocalizableString.Subscriptions.downgradeToFreeplan.localized
                }

                return LocalizableString.Subscriptions.youAreOnPremium.localized
        }
    }
    var ctaFontIcon: FontIcon? {
        switch viewState {
            case .free(_):
                return .sparkles
            case .premium(_):
                let isFreeSelected = selectedPlan?.productId == nil
                if  isFreeSelected {
                    return nil
                }

                return .sparkles
        }
    }
    var ctaBackgroundColor: ColorEnum {
        switch viewState {
            case .free:
                return .crypto
            case .premium(_):
                let isFreeSelected = selectedPlan?.productId == nil
                if  isFreeSelected {
                    return .warningTint
                }

                return .crypto
        }
    }
    var ctaTextColor: ColorEnum {
        switch viewState {
            case .free:
                return .textInverse
            case .premium(_):
                let isFreeSelected = selectedPlan?.productId == nil
                if  isFreeSelected {
                    return .text
                }
                return .textInverse
        }
    }

    var badgeText: String? {
        products.first?.trialPeriodBadgeString
    }
	var failSuccessObject: FailSuccessStateObject?

	private let useCase: MeUseCaseApi
	private var subscribedProduct: StoreProduct?
	private var products: [StoreProduct] = []
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
			let products: [StoreProduct] = try await useCase.getAvailableSubscriptionProducts()
			self.products = products
			self.subscribedProduct = products.first(where: { $0.isSubscribed })

            if let subscribedProduct {
                let freePlan = generateFreePlan(isWarning: true, showPrice: false)
                let plans = [subscribedProduct.toSubscriptionPlan(showPrice: false), freePlan]
                self.selectedPlan = self.subscribedProduct?.toSubscriptionPlan(showPrice: false) ?? freePlan
                viewState = .premium(plans)
            } else {
                let periods = products.compactMap { $0.period?.unit?.tabTitle }
                self.segments = periods

                let sortedProducts = products.sorted(by: { ($0.period?.unit ?? .day) < ($1.period?.unit ?? .day)})
                let plans = sortedProducts.map { [$0.toSubscriptionPlan(showPrice: true), generateFreePlan(isWarning: false, showPrice: true)] }
                viewState = .free(plans)
                self.selectedPlan = self.subscribedProduct?.toSubscriptionPlan(showPrice: true) ?? plans.first?.first
            }
		} catch {
			print(error)
			showFail(errorDescription: error.localizedDescription)
		}
	}

	func continueButtonTapped() {
        switch viewState {
            case .free:
                guard let selectedPlan, let product = products.first(where: { $0.identifier == selectedPlan.productId }) else {
                    return
                }

                Task { @MainActor in
                    do {
                        if product.hasFreeTrial,
                            let mainScene = UIApplication.shared.mainWindowScene {
                            try await AppStore.presentOfferCodeRedeemSheet(in: mainScene)
                            return
                        }

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
            case .premium:
                // Downgrade
                let conf = WXMAlertConfiguration(title: LocalizableString.Subscriptions.downgradeToFreeAlertTitle.localized,
                                                 text: LocalizableString.Subscriptions.downgradeToFreeAlertMessage.localized.attributedMarkdown ?? "",
                                                 canDismiss: false,
                                                 buttonsLayout: .horizontal,
                                                 secondaryButtons: [.init(title: LocalizableString.Subscriptions.downgrade.localized,
                                                                          action: { [weak self] in
                    self?.showDowngradeAlert = false
                    LinkNavigationHelper().openUrl(UIApplication.openSettingsURLString)
                })],
                                                 primaryButtons: [.init(title: LocalizableString.Subscriptions.stayOnPremium.localized,
                                                                        action: { [weak self] in self?.showDowngradeAlert = false})])

                downgradeAlertConfiguration = conf
                showDowngradeAlert = true
        }

	}
}

private extension SubscriptionsViewModel {
    func observeTransactionChanges() {
        useCase.transactionProductsPublisher?.receive(on: DispatchQueue.main).sink { [weak self] _ in
            Task { @MainActor in
                await self?.refresh()
            }
        }.store(in: &cacncellables)


        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                Task { @MainActor in
                    await self?.refresh()
                }
            }
            .store(in: &cacncellables)
    }

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

    func generateFreePlan(isWarning: Bool, showPrice: Bool) -> SubscriptionPlanView.Plan {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = .current
        let price = currencyFormatter.string(from: 0 as NSNumber)
        return .init(fontIcon: .check,
                     title: LocalizableString.Subscriptions.free.localized,
                     subtitle: LocalizableString.Subscriptions.freeSubtitle.localized,
                     offer: nil,
                     isCurrent: subscribedProduct == nil,
                     price: showPrice ? price : nil,
                     period: nil,
                     description: nil,
                     bullets: [LocalizableString.Subscriptions.freeSubscriptionBullet0.localized,
                               LocalizableString.Subscriptions.freeSubscriptionBullet1.localized,
                               LocalizableString.Subscriptions.freeSubscriptionBullet2.localized,
                               LocalizableString.Subscriptions.freeSubscriptionBullet3.localized],
                     productId: nil,
                     isWarning: isWarning,
                     isPremium: false)
    }
}

extension SubscriptionsViewModel: HashableViewModel {
	nonisolated func hash(into hasher: inout Hasher) {}
}
