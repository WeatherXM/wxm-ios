//
//  StoreProduct+.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 11/11/25.
//

import DomainLayer

extension StoreProduct {
	var toSubcriptionViewCard: SubscriptionCardView.Card {
		.init(title: self.name.uppercased(),
			  price: self.displayPrice,
			  description: self.description)
	}
}
