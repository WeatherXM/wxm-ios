//
//  StationsNotificationsView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 8/7/25.
//

import SwiftUI

struct StationsNotificationsView: View {
	@EnvironmentObject var navigationObject: NavigationObject

    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
			.onAppear {
				navigationObject.title = LocalizableString.StationDetails.notVerified.localized
			}
    }
}

#Preview {
	NavigationContainerView {
		StationsNotificationsView()
	}
}
