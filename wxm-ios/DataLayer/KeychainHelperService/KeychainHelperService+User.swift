//
//  KeychainHelperService+User.swift
//  DataLayer
//
//  Created by Pantelis Giazitsis on 7/8/23.
//

import Foundation
import DomainLayer

extension Notification.Name {
    static let keychainHelperServiceUserIsLoggedChanged = Notification.Name("keychainHelperService.userIsLoggedInChanged")
}

extension KeychainHelperService {

    func deleteEmailAndPassword() {
        delete(service: KeychainConstants.saveAccountInfo.service,
               account: KeychainConstants.saveAccountInfo.account)
    }

    func saveEmailAndPasswordToKeychain(email: String, password: String) {
        let emailPasswordCodable = EmailPasswordCodable(email: email, password: password)
        save(emailPasswordCodable,
             service: KeychainConstants.saveAccountInfo.service,
             account: KeychainConstants.saveAccountInfo.account)
    }

    func deleteNetworkTokenResponseFromKeychain() {
        delete(service: KeychainConstants.saveNetworkTokenResponse.service,
               account: KeychainConstants.saveNetworkTokenResponse.account)

        NotificationCenter.default.post(name: .keychainHelperServiceUserIsLoggedChanged,
                                        object: false)
    }

    func saveNetworkTokenResponseToKeychain(item: NetworkTokenResponse) {
        save(item,
             service: KeychainConstants.saveNetworkTokenResponse.service,
             account: KeychainConstants.saveNetworkTokenResponse.account)

        NotificationCenter.default.post(name: .keychainHelperServiceUserIsLoggedChanged,
                                        object: true)
    }

    func getNetworkTokenResponse(enabledAppGroup: Bool = true) -> NetworkTokenResponse? {
        read(service: KeychainConstants.saveNetworkTokenResponse.service,
             account: KeychainConstants.saveNetworkTokenResponse.account,
             type: NetworkTokenResponse.self,
			 enabledAppGroup: enabledAppGroup)
    }

    func isUserLoggedIn() -> Bool {
        read(service: KeychainConstants.saveNetworkTokenResponse.service,
             account: KeychainConstants.saveNetworkTokenResponse.account,
             type: NetworkTokenResponse.self) != nil
    }

    func getUsersEmail() -> String {
        getUsersAccountInfo()?.email ?? ""
    }

	func getUsersAccountInfo(enabledAppGroup: Bool = true) -> EmailPasswordCodable? {
		read(service: KeychainConstants.saveAccountInfo.service,
			 account: KeychainConstants.saveAccountInfo.account,
			 type: EmailPasswordCodable.self,
			 enabledAppGroup: enabledAppGroup)
	}
}
