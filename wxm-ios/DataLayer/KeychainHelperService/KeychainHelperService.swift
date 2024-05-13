//
//  KeychainHelperService.swift
//  DataLayer
//
//  Created by Hristos Condrea on 8/8/22.
//

import Foundation
import DomainLayer
import Toolkit

public final class KeychainHelperService {
	private let accessGroup: String

	public init() {
		guard let teamId: String = Bundle.main.getConfiguration(for: .teamId) else {
			fatalError("Should provide teamId in configuration file")
		}
		
		accessGroup = "\(teamId).group.com.weatherxm.app"
	}

    func save<T>(_ item: T, service: String, account: String) where T: Codable {
        do {
            let data = try JSONEncoder().encode(item)
            save(data, service: service, account: account, enabledAppGroup: true)
        } catch {
            assertionFailure("Fail to encode item for keychain: \(error)")
        }
    }

	func read<T>(service: String, account: String, type: T.Type, enabledAppGroup: Bool = true) -> T? where T: Codable {
        guard let data = read(service: service, account: account, enabledAppGroup: enabledAppGroup) else {
            return nil
        }
        do {
            let item = try JSONDecoder().decode(type, from: data)
            return item
        } catch {
            assertionFailure("Fail to decode item for keychain: \(error)")
            return nil
        }
    }

	func delete(service: String, account: String, enabledAppGroup: Bool = true) {
		let query = getQuery(service: service, account: account, enabledAppGroup: enabledAppGroup) as CFDictionary
        SecItemDelete(query)
    }

	private func save(_ data: Data, service: String, account: String, enabledAppGroup: Bool) {
		var query = getQuery(service: service, account: account, enabledAppGroup: enabledAppGroup)
		query += [kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlock, kSecValueData: data]
        var status = SecItemAdd(query as CFDictionary, nil)

        if status == errSecDuplicateItem {
            // Item already exist, thus update it.
            let query = getQuery(service: service, account: account, enabledAppGroup: enabledAppGroup) as CFDictionary

            let attributesToUpdate = [kSecValueData: data] as CFDictionary

            // Update existing item
            status = SecItemUpdate(query, attributesToUpdate)
        }

        if status != errSecSuccess {
            print("Error: \(status)")
        }
    }

	private func read(service: String, account: String, enabledAppGroup: Bool) -> Data? {
		var query = getQuery(service: service, account: account, enabledAppGroup: enabledAppGroup)
		query += [kSecReturnData: true]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

		// Debug
		if status != errSecSuccess {
			let message = SecCopyErrorMessageString(status, nil) as? String
			let error = NSError(domain: "keychain", code: -1, userInfo: ["message": message, "osStatus": status])
			WXMAnalytics.shared.logError(error)
		}
        
		return (result as? Data)
    }

	private func getQuery(service: String, account: String, enabledAppGroup: Bool) -> [CFString: Any] {
		var query: [CFString: Any] = [kSecAttrService: service,
									  kSecAttrAccount: account,
											kSecClass: kSecClassGenericPassword]
		if enabledAppGroup {
			query += [kSecAttrAccessGroup: accessGroup]
		}
		return query
	}
}
