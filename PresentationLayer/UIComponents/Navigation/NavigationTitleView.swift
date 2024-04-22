//
//  NavigationTitleView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 16/4/24.
//

import SwiftUI

struct NavigationTitleView<V: View>: View {
	@Binding var title: String
	@Binding var subtitle: String?
	var rightView: (() -> V)

    var body: some View {
		HStack {
			VStack(spacing: CGFloat(.mediumSpacing)) {
				VStack(spacing: 0.0) {
					HStack {
						Text(title)
							.font(.system(size: CGFloat(.titleFontSize), weight: .bold))
							.foregroundColor(Color(.text))

						Spacer()
					}

					if let subtitle {
						HStack {
							Text(subtitle)
								.font(.system(size: CGFloat(.normalFontSize)))
								.foregroundColor(Color(.darkGrey))
							Spacer()
						}
					}
				}
			}

			Spacer()

			rightView()
		}
    }
}

#Preview {
	NavigationTitleView(title: .constant("Title"),
						subtitle: .constant("Subtitle")) {
		Text(verbatim: "Right view")
	}
}
