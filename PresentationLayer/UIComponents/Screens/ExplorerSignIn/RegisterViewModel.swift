//
//  RegisterViewModel.swift
//  PresentationLayer
//
//  Created by Hristos Condrea on 23/5/22.
//

import Combine
import DomainLayer
import Toolkit

final class RegisterViewModel: ObservableObject {
    @Published var userEmail: String = ""
    @Published var userName: String = ""
    @Published var userSurname: String = ""
    @Published var isSignUpButtonAvailable: Bool = false
    @Published var isCallInProgress: Bool = false
    @Published var isSuccess: Bool = false
    @Published var isFail = false

    var failSuccessObj: FailSuccessStateObject?
    private var cancellableSet: Set<AnyCancellable> = []

    private final let authUseCase: AuthUseCase

    init(authUseCase: AuthUseCase) {
        self.authUseCase = authUseCase
    }

    func register() {
        do {
            isCallInProgress = true
            try authUseCase.register(email: userEmail, firstName: userName, lastName: userSurname)
                .sink { [weak self] response in
                    guard let self else {
                        return
                    }

                    self.isCallInProgress = false

                    if let error = response.error {
                        let info = error.uiInfo
                        let title = info.title
                        var description = info.description
                        if error.backendError?.code == FailAPICodeEnum.userAlreadyExists.rawValue {
                            description = LocalizableString.Error.signupUserAlreadyExists1.localized + self.userEmail + LocalizableString.Error.signupUserAlreadyExists2.localized
                        }

                        let failObj = FailSuccessStateObject(type: .register,
                                                             title: title,
                                                             subtitle: description?.attributedMarkdown,
                                                             cancelTitle: nil,
                                                             retryTitle: LocalizableString.retry.localized,
                                                             contactSupportAction: {
							HelperFunctions().openContactSupport(successFailureEnum: .register,
																 email: nil,
																 serialNumber: nil,
																 trackSelectContentEvent: true)
                        },
                                                             cancelAction: nil,
                                                             retryAction: { [weak self] in self?.isFail = false })

                        self.failSuccessObj = failObj
                        self.isFail = true
                        self.isSuccess = false
                    } else {
                        let description = LocalizableString.successRegisterDesc1.localized + self.userEmail + LocalizableString.successRegisterDesc2.localized

                        let successObj = FailSuccessStateObject(type: .register,
                                                                title: LocalizableString.success.localized,
                                                                subtitle: description.attributedMarkdown,
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
                    WXMAnalytics.shared.trackEvent(.viewContent, parameters: [.contentName: .signup,
                                                                        .contentId: .signUpContentId,
                                                                        .method: .emailMethod,
                                                                        .success: .custom(isSuccessful ? "1" : "0")])
                }.store(in: &cancellableSet)

        } catch {}
    }

    func checkSignUpButtonAvailability() {
        if userEmail.isEmpty || !userEmail.isValidEmail() {
            isSignUpButtonAvailable = false
        } else {
            isSignUpButtonAvailable = true
        }
    }
}

extension RegisterViewModel: HashableViewModel {
    func hash(into hasher: inout Hasher) {
    }
}
