//
//  KeychainRepositoryImpl.swift
//  DataLayer
//
//  Created by Hristos Condrea on 8/8/22.
//

import DomainLayer
import Foundation

public struct KeychainRepositoryImpl: KeychainRepository {
	public var userLoggedInStateNotificationPublisher: NotificationCenter.Publisher {
		NotificationCenter.default.publisher(for: .keychainHelperServiceUserIsLoggedChanged)
	}

    public func deleteEmailAndPasswordFromKeychain() {
        let keychainHelperService = KeychainHelperService()
        keychainHelperService.deleteEmailAndPassword()
    }

    public func saveEmailAndPasswordToKeychain(email: String, password: String) {
        let keychainHelperService = KeychainHelperService()
        keychainHelperService.saveEmailAndPasswordToKeychain(email: email, password: password)
    }

    public func deleteNetworkTokenResponseFromKeychain() {
        let keychainHelperService = KeychainHelperService()
        keychainHelperService.deleteNetworkTokenResponseFromKeychain()
    }

    public func saveNetworkTokenResponseToKeychain(item: NetworkTokenResponse) {
        let keychainHelperService = KeychainHelperService()
        keychainHelperService.saveNetworkTokenResponseToKeychain(item: item)
    }

    public func isUserLoggedIn() -> Bool {
        let keychainHelperService = KeychainHelperService()
        return keychainHelperService.isUserLoggedIn()
    }

    public func getUsersEmail() -> String {
        let keychainHelperService = KeychainHelperService()
        return keychainHelperService.getUsersEmail()
    }

    public init() {}
}
