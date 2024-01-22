//
//  IPadMaxWidthModifier.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 17/11/23.
//

import Foundation
import SwiftUI
import Toolkit

private struct IPadMaxWidthModifier: ViewModifier {

	func body(content: Content) -> some View {
		content
			.modify { view in
				if UIDevice.current.isIPad {
					view.frame(maxWidth: iPadElementMaxWidth)
				} else {
					view
				}
			}
	}
}

extension View {
	func iPadMaxWidth() -> some View {
		modifier(IPadMaxWidthModifier())
	}
}
