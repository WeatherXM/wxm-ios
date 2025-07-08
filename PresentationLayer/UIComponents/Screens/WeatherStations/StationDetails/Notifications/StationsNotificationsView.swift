//
//  StationsNotificationsView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 8/7/25.
//

import SwiftUI

struct StationsNotificationsView: View {
	@StateObject var viewModel: StationNotificationsViewModel
	@EnvironmentObject var navigationObject: NavigationObject

    var body: some View {
		ScrollView {
			VStack(spacing: CGFloat(.defaultSpacing)) {
				titleView
				Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
			}
			.padding(CGFloat(.defaultSidePadding))
		}
		.scrollIndicators(.hidden)
		.onAppear {
			navigationObject.title = LocalizableString.StationDetails.notifications.localized
		}
	}
}

private extension StationsNotificationsView {
	@ViewBuilder
	var titleView: some View {
		HStack(spacing: CGFloat(.smallToMediumSpacing)) {
			let faIcon = viewModel.followState.state.FAIcon
			Text(faIcon.icon.rawValue)
				.font(.fontAwesome(font: faIcon.font, size: CGFloat(.mediumFontSize)))
				.foregroundColor(Color(colorEnum: faIcon.color))
				.padding(CGFloat(.smallSidePadding))
				.background {
					Color(colorEnum: .layer1)
				}
				.cornerRadius(CGFloat(.buttonCornerRadius))

			Text(viewModel.device.friendlyName ?? "")
				.foregroundStyle(Color(colorEnum: .text))
				.font(.system(size: CGFloat(.smallTitleFontSize)))
			
			Spacer()
		}
	}
}

#Preview {
	NavigationContainerView {
		StationsNotificationsView(viewModel: .init(device: .mockDevice,
												   followState: .init(deviceId: "",
																	  relation: .owned)))
	}
}
