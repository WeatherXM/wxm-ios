//
//  ZoomControls.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 28/6/24.
//

import SwiftUI
import Toolkit

struct ZoomControls: View {
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

					Color(colorEnum: .wxmPrimary)
						.frame(height: 2.0)

					Button {
						zoomOutAction()
					} label: {
						Text(verbatim: "-")
							.padding(CGFloat(.mediumSidePadding))
					}
				}
				.foregroundStyle(Color(colorEnum: .wxmPrimary))
				.font(.system(size: CGFloat(.largeTitleFontSize), weight: .bold))
				.background(Color(colorEnum: .top).cornerRadius(CGFloat(.cardCornerRadius)))
				.strokeBorder(color: Color(colorEnum: .wxmPrimary),
							  lineWidth: 2.0,
							  radius: CGFloat(.cardCornerRadius))
				.fixedSize()

				Spacer()
			}
		}
		.padding(CGFloat(.defaultSidePadding))
    }
}

#Preview {
    ZoomControls(zoomOutAction: {}, zoomInAction: {})
}
