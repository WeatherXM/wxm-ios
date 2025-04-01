//
//  RegisterViewModel.swift
//  PresentationLayer
//
//  Created by Hristos Condrea on 23/5/22.
//

import Combine
import DomainLayer
import Toolkit

@MainActor
final class RegisterViewModel: ObservableObject {
	@Published var userEmail: String = ""
	@Published var userName: String = ""
	@Published var userSurname: String = ""
	@Published var isCallInProgress: Bool = false
	@Published var termsAccepted = false
	@Published var isSuccess: Bool = false
	@Published var isFail = false
	
	var isSignUpButtonAvailable: Bool {
		guard !userEmail.isEmpty &&
				userEmail.isValidEmail() &&
				termsAccepted else {
			return false
		}
		
		return true
	}
	var failSuccessObj: FailSuccessStateObject?
	private var cancellableSet: Set<AnyCancellable> = []
	
	private let authUseCase: AuthUseCaseApi
	private let mainUseCase: MainUseCaseApi

	init(authUseCase: AuthUseCaseApi, mainUseCase: MainUseCaseApi) {
		self.authUseCase = authUseCase
		self.mainUseCase = mainUseCase
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
						self.handleError(error)
					} else {
						handleSuccess()
					}
					
					let isSuccessful = response.error == nil
					WXMAnalytics.shared.trackEvent(.viewContent, parameters: [.contentName: .signup,
																			  .method: .emailMethod,
																			  .success: .custom(isSuccessful ? "1" : "0")])
				}.store(in: &cancellableSet)
			
		} catch {}
	}
	
	func handleError(_ error: NetworkErrorResponse) {
		let info = error.uiInfo
		let title = info.title
		var description = info.description
		if error.backendError?.code == FailAPICodeEnum.userAlreadyExists.rawValue {
			description = LocalizableString.Error.signupUserAlreadyExists1.localized + userEmail + LocalizableString.Error.signupUserAlreadyExists2.localized
		}
		
		let failObj = FailSuccessStateObject(type: .register,
											 title: title,
											 subtitle: description?.attributedMarkdown,
											 cancelTitle: nil,
											 retryTitle: LocalizableString.retry.localized,
											 contactSupportAction: {
			LinkNavigationHelper().openContactSupport(successFailureEnum: .register,
													  email: nil,
													  serialNumber: nil,
													  trackSelectContentEvent: true)
		},
											 cancelAction: nil,
											 retryAction: { [weak self] in self?.isFail = false })
		
		failSuccessObj = failObj
		isFail = true
		isSuccess = false
	}
	
	func handleSuccess() {
		let description = LocalizableString.successRegisterDesc1.localized + userEmail + LocalizableString.successRegisterDesc2.localized
		
		let successObj = FailSuccessStateObject(type: .register,
												title: LocalizableString.success.localized,
												subtitle: description.attributedMarkdown,
												cancelTitle: nil,
												retryTitle: nil,
												contactSupportAction: nil,
												cancelAction: nil,
												retryAction: nil)
		failSuccessObj = successObj
		isFail = false
		isSuccess = true
		
		mainUseCase.setTermsOfUseAccepted()
	}
}

extension RegisterViewModel: HashableViewModel {
	nonisolated func hash(into hasher: inout Hasher) {
	}
}
