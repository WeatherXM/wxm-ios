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
    @Published var isLoggedIn: Bool = false
    @Published var showLoginAlert: Bool = false
    private(set) var loginAlertConfiguration: WXMAlertConfiguration?
    private var cancellableSet: Set<AnyCancellable> = .init()
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

        MainScreenViewModel.shared.$isUserLoggedIn.sink { [weak self] isLoggedIn in
            self?.isLoggedIn = isLoggedIn
        }.store(in: &cancellableSet)
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
        guard isLoggedIn else {
            showLogin()
            return
        }

		let viewModel = ViewModelsFactory.getSubscriptionsViewModel()
		Router.shared.navigateTo(.subscriptions(viewModel))
	}

	func handleManageSubscriptionTap() {
		LinkNavigationHelper().openUrl(DisplayedLinks.appStoreSubscriptions.linkURL)
	}

    func signupButtonTapped() {
        showLoginAlert = false
        Router.shared.navigateTo(.register(ViewModelsFactory.getRegisterViewModel(completion: nil)))
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

    func showLogin() {
        let conf = WXMAlertConfiguration(title: LocalizableString.Subscriptions.getPremium.localized,
                                         text: LocalizableString.Subscriptions.loginToGetPremiumAlert.localized.attributedMarkdown ?? "",
                                         primaryButtons: [.init(title: LocalizableString.login.localized,
                                                                action: { Router.shared.navigateTo(.signIn(ViewModelsFactory.getSignInViewModel())) })])
        loginAlertConfiguration = conf
        showLoginAlert = true
    }
}

extension ManageSubscriptionsViewModel: HashableViewModel {
	nonisolated func hash(into hasher: inout Hasher) { }
}
