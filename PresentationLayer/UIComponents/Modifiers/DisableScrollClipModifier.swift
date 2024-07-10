//
//  DisableScrollClipModifier.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 4/7/24.
//

import SwiftUI
import SwiftUIIntrospect

extension ScrollView {
	func disableScrollClip() -> some View {
		self
			.modify { scrollView in
				if #available(iOS 17.0, *) {
					scrollView.scrollClipDisabled()
				} else {
					introspect(.scrollView, on: (.iOS(.v15, .v16))) { scrollView in
						scrollView.clipsToBounds = false
					}
				}
			}
	}
}
