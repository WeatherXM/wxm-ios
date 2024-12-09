//
//  WXMCapsuleButtonStyle.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 9/12/24.
//

import SwiftUI

struct WXMCapsuleButtonStyle: ButtonStyle {
	@Environment(\.isEnabled) private var isEnabled: Bool

	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.font(.system(size: CGFloat(.normalFontSize), weight: .bold))
			.foregroundStyle(Color(colorEnum: isEnabled ? .top : .darkGrey))
			.padding(.horizontal, CGFloat(.mediumSidePadding))
			.padding(.vertical, CGFloat(.smallSidePadding))
			.background {
				Capsule().fill(Color(colorEnum: isEnabled ? .wxmPrimary : .midGrey))
		}
			.opacity(configuration.isPressed ? 0.7 : 1.0)
	}
}
