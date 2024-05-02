//
//  ClaimDeviceBulletView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 2/5/24.
//

import SwiftUI

struct ClaimDeviceBulletView: View {
	let bullet: Bullet

    var body: some View {
		HStack(alignment: .top, spacing: CGFloat(.smallSpacing)) {
			Text(bullet.fontIcon.rawValue)
				.font(.fontAwesome(font: .FAProSolid, size: CGFloat(.mediumFontSize)))
				.foregroundColor(Color(colorEnum: .text))

			Text(bullet.text)
				.foregroundStyle(Color(colorEnum: .text))
				.font(.system(size: CGFloat(.normalFontSize)))

			Spacer()
		}
    }
}

extension ClaimDeviceBulletView {
	struct Bullet {
		let fontIcon: FontIcon
		let text: AttributedString
	}
}

#Preview {
	ClaimDeviceBulletView(bullet: .init(fontIcon: .circleOne, text: "This is a bullet"))
}
