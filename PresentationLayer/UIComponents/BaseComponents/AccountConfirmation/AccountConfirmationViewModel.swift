//
//  AccountConfirmationViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 14/3/23.
//

import Foundation
import DomainLayer
import Toolkit
import Combine

@MainActor
class AccountConfirmationViewModel: ObservableObject {
    @Published var password: String = "" {
        didSet {
            isConfirmButtonEnabled = !password.trimWhiteSpaces().isEmpty
			textFieldError = nil
        }
    }
    @Published private(set) var isConfirmButtonEnabled: Bool = false
    @Published var textFieldError: TextFieldError?
    @Published var isLoading: Bool = false
    let title: String
    let descriptionMarkdown: String?

	private let useCase: AuthUseCaseApi?
    private let completion: GenericCallback<Bool>?
    private var cancellables: Set<AnyCancellable> = []

	init(title: String, descriptionMarkdown: String? = nil, useCase: AuthUseCaseApi? = nil, completion: GenericCallback<Bool>? = nil) {
        self.title = title
        self.descriptionMarkdown = descriptionMarkdown
        self.useCase = useCase
        self.completion = completion
    }

    func confirmButtonTapped() {
        performLogin()
    }
}

private extension AccountConfirmationViewModel {
    func performLogin() {
        do {
            isLoading = true
            try useCase?.passwordValidation(password: password).sink { [weak self] response in
                self?.isLoading = false

                if let error = response.error {
                    if error.backendError?.code == FailAPICodeEnum.invalidCredentials.rawValue {
                        self?.textFieldError = .invalidPassword
                    } else if let errorMessage = response.error?.uiInfo.description {
						self?.textFieldError = .custom(errorMessage)
                        WXMAnalytics.shared.trackEvent(.viewContent, parameters: [.contentName: .failure,
                                                                            .itemId: .custom(response.error?.backendError?.code ?? "")])
                    }
                } else {
                    self?.textFieldError = nil
                }

                let isValid = response.error == nil
                self?.completion?(isValid)
            }.store(in: &cancellables)
        } catch {
            print(error)
            isLoading = false
            completion?(false)
        }
    }
}
