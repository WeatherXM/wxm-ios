//
//  MyWalletViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 5/4/23.
//

import Foundation
import Combine
import DomainLayer
import Toolkit

class MyWalletViewModel: ObservableObject {
    private let ethAddressPrefix = "0x"
    private let ethAddressLength = 42

    let trackableObject = TrackableScrollOffsetObject()
    @Published var input: String = "" {
        didSet {
            textFieldError = nil
        }
    }
    @Published var textFieldError: TextFieldError?
    @Published var isTermsOfServiceAccepted: Bool = false
    @Published var isOwnershipAcknowledged: Bool = false
    @Published var isWarningVisible: Bool = false
    @Published var isInEditMode: Bool = false
    @Published var showQrScanner: Bool = false
    @Published var showAccountConfirmation: Bool = false
    @Published var isLoading: Bool = false
    @Published var isFailed: Bool = false
    private(set) var failObj: FailSuccessStateObject?
    var isSaveButtonEnabled: Bool {
        isTermsOfServiceAccepted &&
        isOwnershipAcknowledged
    }
    var accountConfirmationViewModel: AccountConfirmationViewModel?
	private let mainVM: MainScreenViewModel = .shared

    private let useCase: MeUseCase?
    private(set) var wallet: Wallet?
    private var cancellableSet: Set<AnyCancellable> = []

    init(useCase: MeUseCase?) {
        self.useCase = useCase
        getUserWallet()
    }

    func handleEditButtonTap() {
        WXMAnalytics.shared.trackEvent(.selectContent, parameters: [.contentType: .editWallet,
                                                              .itemId: .custom(wallet?.address ?? "")])

        accountConfirmationViewModel = AccountConfirmationViewModel(title: LocalizableString.confirmPasswordTitle.localized,
                                                                    descriptionMarkdown: LocalizableString.Wallet.myAccountConfirmationDescription.localized,
                                                                   useCase: SwinjectHelper.shared.getContainerForSwinject().resolve(AuthUseCase.self)) { [weak self] isvalid in
            guard isvalid else {
                return
            }
            self?.showAccountConfirmation = false
            self?.isInEditMode = true
            self?.isWarningVisible = true
        }
        showAccountConfirmation = true
    }

    func handleSaveButtonTap() {
        textFieldError = input.newAddressValidation()
        guard textFieldError == nil else {
            return
        }

        performSaveProcess()
    }

    func handleViewTransactionHistoryTap() {
        let url = String(format: DisplayedLinks.networkAddressWebsiteFormat.linkURL, input)
        HelperFunctions().openUrl(url)

        WXMAnalytics.shared.trackEvent(.selectContent, parameters: [.contentType: .walletTransactions,
                                                              .itemId: .custom(wallet?.address ?? "")])
    }

	func handleCheckCompatibilityTap() {
		WXMAnalytics.shared.trackEvent(.prompt, parameters: [.promptName: .walletCompatibility,
															 .promptType: .info,
															 .action: .action])

		HelperFunctions().openUrl(DisplayedLinks.createWalletsLink.linkURL)
	}

    func handleQRButtonTap() {
        WXMAnalytics.shared.trackEvent(.selectContent, parameters: [.contentType: .scanQRWallet])
        
        showQrScanner = true
    }

	func handleScanResult(result: String?) {
		showQrScanner = false
		guard let result else {
			return
		}

		var input = result

		if let addressFirstIndex = input.firstIndex(substring: ethAddressPrefix),
		   let addressLastIndex = input.index(addressFirstIndex, offsetBy: ethAddressLength, limitedBy: input.endIndex) {
			input = String(input[addressFirstIndex ..< addressLastIndex])
		}

		self.input = input
	}
}

extension MyWalletViewModel: HashableViewModel {
    func hash(into hasher: inout Hasher) {
        hasher.combine(wallet?.address)
    }
}

private extension MyWalletViewModel {
    func getUserWallet() {
        do {
            isLoading = true
            try useCase?.getUserWallet()
                .sink { [weak self] response in
                    self?.isLoading = false

                    if let error = response.error {
                        let info = error.uiInfo
                        let obj = info.defaultFailObject(type: .myWallet) {
                            self?.isFailed = false
                            self?.getUserWallet()
                        }

                        self?.failObj = obj
                        self?.isFailed = true
                    } else {
                        self?.wallet = response.value
                        self?.initializeState()
                    }
                }.store(in: &cancellableSet)
        } catch {}
    }

    func performSaveUserRequest() {
        do {
            LoaderView.shared.show()
            try useCase?.saveUserWallet(address: input)
                .sink { [weak self] response in
                    guard let self = self else {
                        return
                    }

                    LoaderView.shared.dismiss {
                        if let error = response.error {
                            if let message = error.backendError?.message.attributedMarkdown {
                                WXMAnalytics.shared.trackEvent(.viewContent, parameters: [.contentName: .failure,
                                                                                    .itemId: .custom(error.backendError?.code ?? "")])
                                Toast.shared.show(text: message)
                            }
                        } else {
                            self.isInEditMode = false
                            self.isWarningVisible = false
                            Toast.shared.show(text: LocalizableString.addressAdded.localized.attributedMarkdown!, type: .info)
                        }
                    }

                }.store(in: &cancellableSet)
        } catch {}
    }

    func saveUserWallet() {
        let okAction: AlertHelper.AlertObject.Action = (LocalizableString.confirm.localized, { [weak self] _ in self?.performSaveUserRequest() })
        let obj = AlertHelper.AlertObject(title: LocalizableString.Wallet.confirmOwnershipTitle.localized,
                                          message: LocalizableString.Wallet.confirmOwnershipDescription(String(input.suffix(5))).localized,
                                          cancelActionTitle: LocalizableString.cancel.localized,
                                          okAction: okAction)
        DispatchQueue.main.async {
            AlertHelper().showAlert(obj)
        }
    }

    func performSaveProcess() {
        saveUserWallet()
    }

    func initializeState() {
        input = wallet?.address ?? ""
        isInEditMode = (wallet?.address == nil)
        isWarningVisible = isInEditMode
    }
}
