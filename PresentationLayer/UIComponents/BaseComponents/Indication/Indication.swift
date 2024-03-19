//
//  Indication.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 1/11/23.
//

import Foundation
import SwiftUI

private struct IndicationModifier<V: View>: ViewModifier {

	@Binding var show: Bool
	let borderColor: Color
	let bgColor: Color
	let content: () -> V

	func body(content: Content) -> some View {
		if show {
			VStack(spacing: 0.0) {
				content
				self.content()
			}
			.WXMCardStyle(backgroundColor: bgColor, insideHorizontalPadding: 0.0, insideVerticalPadding: 0.0)
			.strokeBorder(color: borderColor, lineWidth: 1.0, radius: CGFloat(.cardCornerRadius))
		} else {
			content
		}
	}
}

extension View {
	@ViewBuilder
	func indication<Content: View>(show: Binding<Bool>,
								   borderColor: Color,
								   bgColor: Color,
								   content: @escaping () -> Content) -> some View {
		modifier(IndicationModifier(show: show, borderColor: borderColor, bgColor: bgColor, content: content))
	}
}

#Preview {
	WeatherStationCard(device: .mockDevice, followState: nil)
		.indication(show: .constant(true), borderColor: .red, bgColor: .red.opacity(0.5)) {
			Text(verbatim: "Indication")
				.padding()
		}
}
