//
//  KeychainUseCase.swift
//  DomainLayer
//
//  Created by Hristos Condrea on 8/8/22.
//

import Foundation

public struct KeychainUseCase {
    private let keychainRepository: KeychainRepository

    public init(keychainRepository: KeychainRepository) {
        self.keychainRepository = keychainRepository
    }

    public func saveNetworkTokenResponseToKeychain(item: NetworkTokenResponse) {
        keychainRepository.saveNetworkTokenResponseToKeychain(item: item)
    }

    public func isUserLoggedIn() -> Bool {
        return keychainRepository.isUserLoggedIn()
    }

    public func deleteNetworkTokenResponseFromKeychain() {
        keychainRepository.deleteNetworkTokenResponseFromKeychain()
    }

    public func saveAccountInfoToKeychain(email: String, password: String) {
        keychainRepository.saveEmailAndPasswordToKeychain(email: email, password: password)
    }

    public func deleteAccountInfoFromKeychain() {
        keychainRepository.deleteEmailAndPasswordFromKeychain()
    }

    public func getUsersEmail() -> String {
        keychainRepository.getUsersEmail()
    }
}
