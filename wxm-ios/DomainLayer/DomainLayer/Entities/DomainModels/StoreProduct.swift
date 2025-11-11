//
//  StoreProduct.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 11/11/25.
//

import Foundation
import StoreKit

public struct StoreProduct {
	public let identifier: String
	public let name: String
	public let description: String
	public let displayPrice: String
	public let isSubscribed: Bool

	init(product: Product, isSubscribed: Bool) {
		self.identifier = product.id
		self.name = product.displayName
		self.description = product.description
		self.displayPrice = product.displayPrice
		self.isSubscribed = isSubscribed
	}
}
