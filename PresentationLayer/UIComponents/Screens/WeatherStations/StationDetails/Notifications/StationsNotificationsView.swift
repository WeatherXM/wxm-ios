//
//  StationsNotificationsView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 8/7/25.
//

import SwiftUI
import DomainLayer

struct StationsNotificationsView: View {
	@StateObject var viewModel: StationNotificationsViewModel
	@EnvironmentObject var navigationObject: NavigationObject

    var body: some View {
		ZStack {
			Color(colorEnum: .top)
				.ignoresSafeArea()
			ScrollView {
				VStack(spacing: CGFloat(.defaultSpacing)) {
					titleView

					optionView(title: LocalizableString.StationDetails.showNotifications.localized,
							   description: nil,
							   switchOn: Binding(get: {
						viewModel.masterSwitchValue
					}, set: { value in
						viewModel.setMasterSwitchValue(value)
					}))

					WXMDivider()

					ForEach(viewModel.availableNotifications, id: \.self) { notificationType in
						optionView(title: notificationType.title,
								   description: notificationType.description,
								   switchOn: .init(get: {
							viewModel.options[notificationType] ?? false
						}, set: { value in
							viewModel.setValue(value, for: notificationType)
						}))
						.disabled(!viewModel.masterSwitchValue)
					}
				}
				.padding(CGFloat(.defaultSidePadding))
			}
			.scrollIndicators(.hidden)
		}
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

			Text(viewModel.device.displayName)
				.foregroundStyle(Color(colorEnum: .text))
				.font(.system(size: CGFloat(.smallTitleFontSize)))

			Spacer()
		}
	}

	@ViewBuilder
	func optionView(title: String,
					description: String?,
					switchOn: Binding<Bool>) -> some View {
		HStack {
			VStack(alignment: .leading, spacing: CGFloat(.minimumSpacing)) {
				Text(title)
					.foregroundStyle(Color(colorEnum: .text))
					.font(.system(size: CGFloat(.smallTitleFontSize)))

				if let description {
					Text(description)
						.foregroundStyle(Color(colorEnum: .text))
						.font(.system(size: CGFloat(.normalFontSize)))
						.fixedSize(horizontal: false, vertical: true)
				}
			}

			Spacer()

			Toggle("", isOn: switchOn)
				.labelsHidden()
				.toggleStyle(WXMToggleStyle.Default)
		}
	}
}

#Preview {
	NavigationContainerView {
		StationsNotificationsView(viewModel: ViewModelsFactory.getStationNotificationsViewModel(device: .mockDevice,
																								followState: .init(deviceId: "", relation: .owned)))
	}
}
