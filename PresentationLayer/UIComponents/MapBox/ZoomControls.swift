//
//  ZoomControls.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 28/6/24.
//

import SwiftUI
import Toolkit

struct ZoomControls: View {
	@Binding var controlsBottomOffset: CGFloat
	let zoomOutAction: VoidCallback
	let zoomInAction: VoidCallback

    var body: some View {
		VStack {
			Spacer()
			HStack {
				VStack(spacing: 0.0) {
					Button {
						zoomInAction()
					} label: {
						Text(verbatim: "+")
							.padding(CGFloat(.mediumSidePadding))
					}

					Color(colorEnum: .primary)
						.frame(height: 2.0)

					Button {
						zoomOutAction()
					} label: {
						Text(verbatim: "-")
							.padding(CGFloat(.mediumSidePadding))
					}
				}
				.foregroundStyle(Color(colorEnum: .primary))
				.font(.system(size: CGFloat(.largeTitleFontSize), weight: .bold))
				.background(Color(colorEnum: .top).cornerRadius(CGFloat(.cardCornerRadius)))
				.strokeBorder(color: Color(colorEnum: .primary),
							  lineWidth: 2.0,
							  radius: CGFloat(.cardCornerRadius))
				.fixedSize()

				Spacer()
			}
		}
		.padding(CGFloat(.defaultSidePadding))
		.padding(.bottom, controlsBottomOffset)
    }
}

#Preview {
    ZoomControls(controlsBottomOffset: .constant(0.0), zoomOutAction: {}, zoomInAction: {})
}
