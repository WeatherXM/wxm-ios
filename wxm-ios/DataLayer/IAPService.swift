//
//  IAPService.swift
//  DataLayer
//
//  Created by Pantelis Giazitsis on 6/11/25.
//

import Foundation
import StoreKit
import Combine

public class IAPService: NSObject {

	public func fetchAvailableProducts(for identifiers: [String]) async throws -> [Product] {
		try await Product.products(for: identifiers)
	}
}
