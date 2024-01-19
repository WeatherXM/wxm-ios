//
//  View+.swift
//  station-widgetExtension
//
//  Created by Pantelis Giazitsis on 20/10/23.
//

import Foundation
import SwiftUI

private struct WidgetBackgroundModifier<V: View>: ViewModifier {
	let background: () -> V

	func body(content: Content) -> some View {
		if #available(iOSApplicationExtension 17.0, *) {
			content
				.containerBackground(for: .widget) {
					background()
				}
		} else {
			ZStack {
				background().ignoresSafeArea()
				content
			}
		}
	}
}

extension View {
	@ViewBuilder
	func widgetBackground<Content: View>(_ content: @escaping () -> Content) -> some View {
		modifier(WidgetBackgroundModifier(background: content))
	}
}
