//
//  IAPService.swift
//  DataLayer
//
//  Created by Pantelis Giazitsis on 6/11/25.
//

import Foundation
import StoreKit
import Combine

public class IAPService: @unchecked Sendable {
	public let transactionsPublisher: AnyPublisher<Transaction, Never>
	private var updates: Task<Void, Never>?
	private let transactionsPassthroughSubject: PassthroughSubject<Transaction, Never>


	public init() {
		transactionsPassthroughSubject = .init()
		transactionsPublisher = transactionsPassthroughSubject.eraseToAnyPublisher()
		updates = observeUpdates()
	}

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
				if case .verified(let transaction) = verificationResult {
					await transaction.finish()
				}
			case .userCancelled:
				throw IAPEerror.purchaseCancelled
			case .pending:
				throw IAPEerror.purchaseIsPending
			@unknown default:
				throw IAPEerror.purchaseFailed
		}
	}
}

private extension IAPService {
	func observeUpdates() -> Task<Void, Never> {
		Task(priority: .background) { [weak self] in
			for await result in Transaction.updates {
				self?.handleTransactionResult(result)
			}
		}
	}

	func handleTransactionResult(_ result: VerificationResult<Transaction>) {
		guard case .verified(let transaction) = result else {
			return
		}
		transactionsPassthroughSubject.send(transaction)
	}
}

public extension IAPService {
	enum IAPEerror: Error {
		case noProductWithId(String)
		case purchaseCancelled
		case purchaseIsPending
		case purchaseFailed

		var localiizedDescription: String {
			switch self {
				case .noProductWithId(let string):
					"No product with id: \(string)"
				case .purchaseCancelled:
					"Purchase cancelled"
				case .purchaseIsPending:
					"Purchase is pending"
				case .purchaseFailed:
					"Purchase failed"
			}
		}
	}
}
