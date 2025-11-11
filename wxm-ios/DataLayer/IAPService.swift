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

	public func isEntitled(to productID: String) async -> Bool {
		for await result in Transaction.currentEntitlements {
			if case .verified(let transaction) = result, transaction.productID == productID {
				return true
			}
		}
		return false
	}

	public func getEntitledProductIds() async -> Set<String> {
		var set = Set<String>()
		for await result in Transaction.currentEntitlements {
			if case .verified(let transaction) = result {
				let productID = transaction.productID
				set.insert(productID)
			}
		}

		return set
	}

	public func purchase(productId: String) async throws {
		guard let product = try await fetchAvailableProducts(for: [productId]).first else {
			throw IAPEerror.noProductWithId(productId)
		}

		let result = try await product.purchase()
		switch result {
			case .success(let verificationResult):
				break
			case .userCancelled:
				throw IAPEerror.purchaseCancelled
			case .pending:
				throw IAPEerror.purchaseIsPending
			@unknown default:
				throw IAPEerror.purchaseFailed
		}
	}
}

public extension IAPService {
	enum IAPEerror: Error {
		case noProductWithId(String)
		case purchaseCancelled
		case purchaseIsPending
		case purchaseFailed
	}
}
