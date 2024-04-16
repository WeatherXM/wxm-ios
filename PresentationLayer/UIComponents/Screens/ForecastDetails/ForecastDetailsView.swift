//
//  ForecastDetailsView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 16/4/24.
//

import SwiftUI

struct ForecastDetailsView: View {
	@StateObject var viewModel: ForecastDetailsViewModel
	@EnvironmentObject var navigationObject: NavigationObject

	var body: some View {
		ZStack {
			Color(colorEnum: .newBG)
				.ignoresSafeArea()

			ScrollView(showsIndicators: false) {
				VStack(spacing: CGFloat(.mediumSpacing)) {
					NavigationTitleView(title: .constant(viewModel.device.displayName),
										subtitle: .constant(viewModel.device.address)) {
						Group {
							if let faIcon = viewModel.followState?.state.FAIcon {
								Text(faIcon.icon.rawValue)
									.font(.fontAwesome(font: faIcon.font, size: CGFloat(.mediumFontSize)))
									.foregroundColor(Color(colorEnum: faIcon.color))
							} else {
								EmptyView()
							}
						}
					}
				}.padding(.horizontal, CGFloat(.mediumSidePadding))
			}
		}.onAppear {
			navigationObject.navigationBarColor = Color(.newBG)
		}
	}
}

#Preview {
	NavigationContainerView {
		ForecastDetailsView(viewModel: ViewModelsFactory.getForecastDetailsViewModel(device: .mockDevice,
																					 followState: .init(deviceId: "", relation: .owned)))
	}
}
