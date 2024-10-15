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
					titleView
					
					VStack(spacing: CGFloat(.mediumSpacing)) {
						
						ForEach(viewModel.alerts, id: \.message) { alert in
							CardWarningView(configuration: .init(type: alert.type,
																 icon: alert.icon,
																 title: alert.title,
																 message: alert.message,
																 showBorder: true,
																 closeAction: nil),
											showContentFullWidth: true) {
								Button(action: alert.buttonAction) {
									Text(alert.buttonTitle)
								}
								.buttonStyle(WXMButtonStyle.transparent)
								.padding(.top, CGFloat(.smallSidePadding))
							}
											.onAppear(perform: alert.appearAction)
											.wxmShadow()
						}.iPadMaxWidth()
					}
				}
				.padding(.horizontal, CGFloat(.defaultSidePadding))
			}
		}
	}
}

private extension MultipleAlertsView {
	@ViewBuilder
	var titleView: some View {
		VStack(spacing: CGFloat(.smallSpacing)) {
			HStack {
				Text(LocalizableString.alerts.localized)
					.font(.system(size: CGFloat(.largeTitleFontSize), weight: .bold))
					.lineLimit(1)
					.truncationMode(.middle)
					.foregroundColor(Color(colorEnum: .text))

				Spacer()
			}

			HStack {
				Text(viewModel.device.displayName)
					.font(.system(size: CGFloat(.caption)))
					.foregroundColor(Color(colorEnum: .darkGrey))

				Spacer()
			}
		}
	}
}

extension MultipleAlertsView {
    struct Alert {
        let type: CardWarningType
        let title: String
        let message: String
		let icon: FontIcon?
        let buttonTitle: String
        let buttonAction: VoidCallback
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
