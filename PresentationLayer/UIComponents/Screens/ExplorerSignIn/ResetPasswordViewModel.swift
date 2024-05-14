//
//  ResetPasswordViewModel.swift
//  PresentationLayer
//
//  Created by Hristos Condrea on 30/5/22.
//

import Combine
import DomainLayer
import Toolkit

final class ResetPasswordViewModel: ObservableObject {
    @Published var userEmail: String = ""
    @Published var isSendResetPasswordButtonAvailable: Bool = false
    @Published var isCallInProgress: Bool = false
    @Published var isSuccess: Bool = false
    @Published var isFail = false

    var failSuccessObj: FailSuccessStateObject?
    private var cancellableSet: Set<AnyCancellable> = []

    private final let authUseCase: AuthUseCase

    init(authUseCase: AuthUseCase) {
        self.authUseCase = authUseCase
    }

    func resetPassword() {
        do {
            isCallInProgress = true
            try authUseCase.resetPassword(email: userEmail)
                .sink { [weak self] response in
                    guard let self else {
                        return
                    }
                    self.isCallInProgress = false

                    if let error = response.error {
                        let info = error.uiInfo
                        let failObj = info.defaultFailObject(type: .resetPassword) {[weak self] in
                            self?.isFail = false
                        }

                        self.failSuccessObj = failObj
                        self.isFail = true
                        self.isSuccess = false
                    } else {
                        let successObj = FailSuccessStateObject(type: .resetPassword,
                                                                title: LocalizableString.successResetPasswordTitle.localized,
                                                                subtitle: LocalizableString.successResetPasswordDesc.localized.attributedMarkdown,
                                                                cancelTitle: nil,
                                                                retryTitle: nil,
                                                                contactSupportAction: nil,
                                                                cancelAction: nil,
                                                                retryAction: nil)
                        self.failSuccessObj = successObj
                        self.isFail = false
                        self.isSuccess = true
                    }

                    let isSuccessful = response.error == nil
                    WXMAnalytics.shared.trackEvent(.viewContent, parameters: [.contentName: .sendEmailForgotPassword,
                                                                        .contentId: .forgotPasswordEmailContentId,
                                                                        .success: .custom(isSuccessful ? "1" : "0")])
                }.store(in: &cancellableSet)
        } catch {}
    }

    func isResetPasswordButtonAvailable() {
        isSendResetPasswordButtonAvailable = !userEmail.isEmpty && userEmail.isValidEmail()
    }
}

extension ResetPasswordViewModel: HashableViewModel {
    func hash(into hasher: inout Hasher) {
    }
}
