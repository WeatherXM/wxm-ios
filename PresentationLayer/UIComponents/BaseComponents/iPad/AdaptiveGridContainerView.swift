//
//  AdaptiveGridContainerView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 16/11/23.
//

import SwiftUI
import Toolkit

struct AdaptiveGridContainerView<Content: View>: View {
	private let threshold: CGFloat = iPadElementMaxWidth
	@State private var containerSize: CGSize = .zero

	var spacing: CGFloat = CGFloat(.defaultSpacing)
	let content: () -> Content
	
    var body: some View {
		ZStack {
			if UIDevice.current.isIPad {
				iPadLayout()
			} else {
				iPhoneLayout()
			}
		}
		.sizeObserver(size: $containerSize)
    }
}

private extension AdaptiveGridContainerView {
	@ViewBuilder
	func iPadLayout() -> some View {
		if containerSize.width <= threshold {
			VStack(spacing: spacing) {
				content()
			}
		} else {
			LazyVGrid(columns: [GridItem(.flexible(minimum: 10.0), spacing: spacing),
								GridItem(.flexible(minimum: 10.0), spacing: spacing)],
					  spacing: spacing) {
				content()
			}
		}
	}

	@ViewBuilder
	func iPhoneLayout() -> some View {
		VStack(spacing: spacing) {
			content()
		}
	}
}

#Preview {
	VStack {
		Text(verbatim: "Adaptive")
		AdaptiveGridContainerView {
			ForEach(0...10, id: \.self) { num in
				HStack {
					Spacer()

					Text(verbatim: "\(num)")
						.padding()

					Spacer()
				}
				.background(Color.blue)
			}
		}
	}
}
