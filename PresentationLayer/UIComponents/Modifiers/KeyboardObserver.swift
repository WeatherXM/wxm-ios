//
//  KeyboardObserver.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 31/7/25.
//

import Foundation
import SwiftUI

struct KeyboardObserver: ViewModifier {

	var keyboardIsVisible: Binding<Bool>

	func body(content: Content) -> some View {
		content
			.onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification),
					   perform: { _ in
				keyboardIsVisible.wrappedValue = true
			}).onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification),
						 perform: { _ in
				keyboardIsVisible.wrappedValue = false
			})
	}
}


public extension View {
	func keyboardObserver(_ state: Binding<Bool>) -> some View {
		self.modifier(KeyboardObserver(keyboardIsVisible: state))
	}
}
