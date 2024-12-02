//
//  NetworkErrorResponse+.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 4/7/23.
//

import Foundation
import DomainLayer
import Toolkit

@MainActor
extension NetworkErrorResponse {
	struct UIInfo {
		let title: String
		let description: String?

#if MAIN_APP
		@MainActor
		func defaultFailObject(type: SuccessFailEnum,
										  failMode: FailView.Mode = .default,
										  retryAction: VoidCallback?) -> FailSuccessStateObject {
			let obj = FailSuccessStateObject(type: type,
											 failMode: failMode,
											 title: title,
											 subtitle: description?.attributedMarkdown,
											 cancelTitle: nil,
											 retryTitle: LocalizableString.retry.localized,
											 contactSupportAction: {
				HelperFunctions().openContactSupport(successFailureEnum: type,
													 email: MainScreenViewModel.shared.userInfo?.email,
													 serialNumber: nil,
													 errorString: description)
			},
											 cancelAction: nil,
											 retryAction: retryAction)

			return obj
		}
#endif
	}

	var uiInfo: UIInfo {
		let title = LocalizableString.Error.genericMessage.localized
		var description: String?
		if let error = (initialError.underlyingError as? URLError) {
			if error.code == .notConnectedToInternet || error.code == .timedOut {
				description = LocalizableString.Error.noInternetAccess.localized
			} else {
				description = error.localizedDescription
			}
		} else if let backendError = backendError {
			let code = FailAPICodeEnum(rawValue: backendError.code)
			description = code?.description ?? backendError.message
		}

		return UIInfo(title: title, description: description)
	}

	func uiInfo(title: String? = nil, description: String? = nil) -> UIInfo {
		let info = uiInfo
		return UIInfo(title: title ?? info.title, description: description ?? info.description)
	}
}

private extension FailAPICodeEnum {
	var description: String? {
		switch self {
			case .invalidUsername:
				// Will be handled from the caller
				return nil
			case .invalidPassword:
				// Will be handled from the caller
				return nil
			case .invalidCredentials:
				return LocalizableString.Error.loginInvalidCredentials.localized
			case .userAlreadyExists:
				// Will be handled from the caller
				return nil
			case .invalidAccessToken:
				return LocalizableString.ClaimDevice.errorGeneric.localized
			case .deviceNotFound:
				return LocalizableString.Error.userDeviceNotFound.localized
			case .invalidWalletAddress:
				return LocalizableString.Wallet.connectErrorInvalidAddress.localized
			case .invalidFriendlyName:
				return nil
			case .invalidFromDate:
				return nil
			case .invalidToDate:
				return nil
			case .invalidTimezone:
				return nil
			case .invalidClaimId:
				return nil
			case .invalidClaimLocation:
				return LocalizableString.ClaimDevice.errorInvalidLocation.localized
			case .deviceAlreadyClaimed:
				return LocalizableString.ClaimDevice.alreadyClaimed.localized
			case .deviceClaiming:
				return nil
			case .unauthorized:
				return nil
			case .userNotFound:
				return nil
			case .forbidden:
				return nil
			case .validation:
				return nil
			case .notFound:
				return nil
			case .walletAddressNotFound:
				return nil
			case .unsupportedApplicationVersion:
				return LocalizableString.Error.unsupportedApplicationVersion.localized
		}
	}
}
