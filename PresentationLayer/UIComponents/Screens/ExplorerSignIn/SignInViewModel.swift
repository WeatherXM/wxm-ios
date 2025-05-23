//
//  SignInViewModel.swift
//  PresentationLayer
//
//  Created by Hristos Condrea on 18/5/22.
//

import Combine
import DomainLayer
import Toolkit

@MainActor
final class SignInViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isSignInButtonAvailable: Bool = false
    private var cancellableSet: Set<AnyCancellable> = []
	private final let authUseCase: AuthUseCaseApi

	public init(authUseCase: AuthUseCaseApi) {
        self.authUseCase = authUseCase
    }

    public func login(completion: @escaping (String?) -> Void) {
        isSignInButtonAvailable = false
        do {
            try authUseCase.login(username: email, password: password)
                .sink { response in
                    if let responseError = response.error {
                        self.isSignInButtonAvailable = true
                        let info = responseError.uiInfo
                        let text = info.description ?? LocalizableString.Error.genericMessage.localized
                        completion(text)
                        Toast.shared.show(text: text.attributedMarkdown ?? "")
                    } else {
                        self.isSignInButtonAvailable = true
                        completion(nil)
                    }

                    let isSuccessful = response.error == nil
					WXMAnalytics.shared.trackEvent(.viewContent, parameters: [.contentName: .login,
																			  .method: .emailMethod,
																			  .success: .custom(isSuccessful ? "1" : "0")])

                }.store(in: &cancellableSet)
        } catch {}
    }

    func checkSignInButtonAvailability() {
        if email.isEmpty || password.isEmpty {
            isSignInButtonAvailable = false
        } else {
            isSignInButtonAvailable = true
        }
    }
}

extension SignInViewModel: HashableViewModel {
	nonisolated func hash(into hasher: inout Hasher) {
    }
}
