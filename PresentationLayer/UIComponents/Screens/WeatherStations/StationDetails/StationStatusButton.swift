//
//  StationStatusButton.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 14/10/24.
//

import SwiftUI
import DomainLayer
import Toolkit

struct StationStatusButton: View {
	let followState: UserDeviceFollowState?
	var action: VoidCallback?

	var body: some View {
		Button {
			action?()
		} label: {
			if let faIcon = followState?.state.FAIcon {
				Text(faIcon.icon.rawValue)
					.font(.fontAwesome(font: faIcon.font, size: CGFloat(.mediumFontSize)))
					.foregroundColor(Color(colorEnum: faIcon.color))
			} else {
				Text(FontIcon.heart.rawValue)
					.font(.fontAwesome(font: .FAPro, size: CGFloat(.mediumFontSize)))
					.foregroundColor(Color(colorEnum: .toastErrorBg))
			}
		}
	}
}

#Preview {
	StationStatusButton(followState: nil)
}
