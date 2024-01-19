//
//  KeychainHelperService.swift
//  DomainLayer
//
//  Created by Danae Kikue Dimou on 30/5/22.
//

import Foundation

public final class KeychainHelperService {
    public static let standard = KeychainHelperService()
    private init() {}

    public func save<T>(_ item: T, service: String, account: String) where T: Codable {
        guard let serviceFromConfig = Bundle.main.infoDictionary?[service] as? String else {
            return
        }
        guard let accountFromConfig = Bundle.main.infoDictionary?[account] as? String else {
            return
        }
        do {
            let data = try JSONEncoder().encode(item)
            save(data, service: serviceFromConfig, account: accountFromConfig)
        } catch {
            assertionFailure("Fail to encode item for keychain: \(error)")
        }
    }

    public func read<T>(service: String, account: String, type: T.Type) -> T? where T: Codable {
        guard let serviceFromConfig = Bundle.main.infoDictionary?[service] as? String else {
            return nil
        }
        guard let accountFromConfig = Bundle.main.infoDictionary?[account] as? String else {
            return nil
        }
        // Read item data from keychain
        guard let data = read(service: serviceFromConfig, account: accountFromConfig) else {
            return nil
        }

        // Decode JSON data to object
        do {
            let item = try JSONDecoder().decode(type, from: data)
            return item
        } catch {
            assertionFailure("Fail to decode item for keychain: \(error)")
            return nil
        }
    }

    public func delete(service: String, account: String) {
        let query = [
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecClass: kSecClassGenericPassword,
        ] as CFDictionary

        SecItemDelete(query)
    }

    private func save(_ data: Data, service: String, account: String) {
        let query = [
            kSecValueData: data,
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
        ] as CFDictionary

        var status = SecItemAdd(query, nil)

        if status == errSecDuplicateItem {
            // Item already exist, thus update it.
            let query = [
                kSecAttrService: service,
                kSecAttrAccount: account,
                kSecClass: kSecClassGenericPassword,
            ] as CFDictionary

            let attributesToUpdate = [kSecValueData: data] as CFDictionary

            // Update existing item
            status = SecItemUpdate(query, attributesToUpdate)
        }

        if status != errSecSuccess {
            print("Error: \(status)")
        }
    }

    private func read(service: String, account: String) -> Data? {
        let query = [
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecClass: kSecClassGenericPassword,
            kSecReturnData: true,
        ] as CFDictionary

        var result: AnyObject?
        SecItemCopyMatching(query, &result)

        return (result as? Data)
    }
}
