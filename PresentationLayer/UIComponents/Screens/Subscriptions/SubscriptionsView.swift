//
//  SubscriptionsView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 7/11/25.
//

import SwiftUI
import StoreKit

struct SubscriptionsView: View {
    var body: some View {
		ZStack {
			Color(colorEnum: .bg)
				.ignoresSafeArea()

			if #available(iOS 17.0, *) {
				SubscriptionStoreView(groupID: "21826160")
					
			} else {
				// Fallback on earlier versions
			}
		}
    }
}

#Preview {
    SubscriptionsView()
}
