//
//  LocalizableString+Wallet.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 5/9/23.
//

import Foundation

extension LocalizableString {
	enum Wallet {
		case myWallet
		case enterWallet
		case createMetaMaskLink(String)
		case compatibility
		case compatibilityDescription
		case compatibilityCheckLink(String)
		case editAddress
		case viewTransactionHistory
		case myAccountConfirmationDescription
		case saveAddress
		case connectImportantInformation
		case newWXMAddress
		case currentAddress
		case addressTextFieldCaption
		case notExistingText
		case acceptTermsOfService
		case acknowledgementOfOwnership
		case termsTitle
		case connectErrorInvalidAddress
		case confirmOwnershipTitle
		case confirmOwnershipDescription(String)
		case scanQRCodeButton
		case enterAddressTitle
	}
}

extension LocalizableString.Wallet: WXMLocalizable {
	var localized: String {
		var localized = NSLocalizedString(self.key, comment: "")
		switch self {
			case .confirmOwnershipDescription(let text),
					.createMetaMaskLink(let text),
					.compatibilityCheckLink(let text):
				localized = String(format: localized, text)
			default:
				break
		}

		return localized
	}

	var key: String {
		switch self {
			case .myWallet:
				return "wallet_my_wallet_title"
			case .enterWallet:
				return "wallet_enter_wallet"
			case .createMetaMaskLink:
				return "wallet_create_meta_mask_link"
			case .compatibility:
				return "wallet_compatibility"
			case .compatibilityDescription:
				return "wallet_compatibility_description"
			case .compatibilityCheckLink:
				return "wallet_compatibility_check_link"
			case .editAddress:
				return "wallet_edit_address"
			case .viewTransactionHistory:
				return "wallet_view_transaction_history"
			case .myAccountConfirmationDescription:
				return "wallet_my_account_confirmation_description"
			case .saveAddress:
				return "wallet_save_address"
			case .connectImportantInformation:
				return "wallet_connect_important_information"
			case .newWXMAddress:
				return "wallet_new_wxm_address"
			case .currentAddress:
				return "wallet_current_address"
			case .addressTextFieldCaption:
				return "wallet_address_text_field_caption"
			case .notExistingText:
				return "wallet_not_existing_text"
			case .acceptTermsOfService:
				return "wallet_accept_terms_of_service"
			case .acknowledgementOfOwnership:
				return "wallet_acknowledgement_of_ownership"
			case .termsTitle:
				return "wallet_terms_title"
			case .connectErrorInvalidAddress:
				return "wallet_connect_error_invalid_address"
			case .confirmOwnershipTitle:
				return "wallet_confirm_ownership_title"
			case .confirmOwnershipDescription:
				return "wallet_confirm_ownership_description_format"
			case .scanQRCodeButton:
				return "wallet_scan_qr_code_button"
			case .enterAddressTitle:
				return "wallet_enter_address_title"
		}
	}
}
