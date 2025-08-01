//
//  HomeLocationPermissionView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 1/8/25.
//

import SwiftUI

struct HomeLocationPermissionView: View {
    var body: some View {
		HStack(spacing: CGFloat(.defaultSpacing)) {
			Text(FontIcon.locationDot.rawValue)
				.font(.fontAwesome(font: .FAProSolid, size: CGFloat(.largeTitleFontSize)))
				.foregroundStyle(Color(colorEnum: .wxmPrimary))

			Text(LocalizableString.Home.allowLocationPermission.localized)
				.multilineTextAlignment(.leading)
				.font(.system(size: CGFloat(.normalFontSize)))

			Spacer()
		}
		.WXMCardStyle()
    }
}

#Preview {
	ZStack {
		Color(colorEnum: .bg)
		
		HomeLocationPermissionView()
	}
}
