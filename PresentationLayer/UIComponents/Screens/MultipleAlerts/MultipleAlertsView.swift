//
//  MultipleAlertsView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 26/5/23.
//

import SwiftUI
import DomainLayer
import Toolkit

struct MultipleAlertsView: View {
    @EnvironmentObject var navigationObject: NavigationObject
    @StateObject var viewModel: AlertsViewModel

	var body: some View {
		ZStack {
			Color(colorEnum: .top)
			
			ScrollView {
				VStack(spacing: CGFloat(.largeSpacing)) {
					VStack(spacing: CGFloat(.mediumSpacing)) {
						
						ForEach(viewModel.alerts, id: \.message) { alert in
							CardWarningView(configuration: .init(type: alert.type,
																 icon: alert.icon,
																 title: alert.title,
																 message: alert.message,
																 showBorder: true,
																 closeAction: nil),
											showContentFullWidth: true) {
								Group {
									if let buttonTitle = alert.buttonTitle,
									   let buttonAction = alert.buttonAction {
										Button(action: buttonAction) {
											Text(buttonTitle)
										}
										.buttonStyle(WXMButtonStyle.transparent)
										.padding(.top, CGFloat(.smallSidePadding))
									} else {
										EmptyView()
									}
								}
							}
											.onAppear(perform: alert.appearAction)
											.wxmShadow()
						}.iPadMaxWidth()
					}
				}
				.padding(.horizontal, CGFloat(.defaultSidePadding))
			}
		}
		.onAppear {
			navigationObject.title = LocalizableString.alerts.localized
			navigationObject.titleFont = .system(size: CGFloat(.largeTitleFontSize),
												 weight: .bold)
			navigationObject.subtitle = viewModel.device.displayName
			navigationObject.subtitleFont = .system(size: CGFloat(.caption))

			viewModel.viewAppeared()
		}
	}
}

extension MultipleAlertsView {
    struct Alert {
        let type: CardWarningType
        let title: String
        let message: String
		let icon: FontIcon?
        let buttonTitle: String?
        let buttonAction: VoidCallback?
        let appearAction: VoidCallback?
    }
}

struct MultipleAlertsView_Previews: PreviewProvider {
    static var previews: some View {
        let mainVM = MainScreenViewModel.shared
        NavigationContainerView {
            MultipleAlertsView(viewModel: AlertsViewModel(device: .mockDevice,
														  mainVM: mainVM,
														  followState: .init(deviceId: "123",
																			 relation: .owned)))
        }
    }
}
