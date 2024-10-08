//
//  KeychainRepository.swift
//  DomainLayer
//
//  Created by Hristos Condrea on 8/8/22.
//

import Foundation

public protocol KeychainRepository {
	var userLoggedInStateNotificationPublisher: NotificationCenter.Publisher { get }
    func saveNetworkTokenResponseToKeychain(item: NetworkTokenResponse)
    func isUserLoggedIn() -> Bool
    func deleteNetworkTokenResponseFromKeychain()
    func saveEmailAndPasswordToKeychain(email: String, password: String)
    func deleteEmailAndPasswordFromKeychain()
    func getUsersEmail() -> String
}
