//
//  WXMButtonOpacityStyle.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 9/12/24.
//

import SwiftUI

struct WXMButtonOpacityStyle: ButtonStyle {
	@Environment(\.isEnabled) private var isEnabled: Bool

	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.opacity(configuration.isPressed ? 0.7 : 1.0)
			.opacity(isEnabled ? 1.0 : 0.4)
	}
}
