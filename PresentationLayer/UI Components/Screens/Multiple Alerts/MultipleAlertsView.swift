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
                VStack(spacing: CGFloat(.smallSpacing)) {
                    ForEach(viewModel.alerts, id: \.message) { alert in
                        CardWarningView(type: alert.type,
                                        title: alert.title,
                                        message: alert.message,
                                        showContentFullWidth: true,
                                        closeAction: nil) {
                            Button(action: alert.buttonAction) {
                                Text(alert.buttonTitle)
                            }
                            .buttonStyle(WXMButtonStyle())
                            .padding(.top, CGFloat(.smallSidePadding))
                        }
                        .onAppear(perform: alert.appearAction)
                    }
                }
                .padding(CGFloat(.defaultSidePadding))
            }
            .onAppear {
                navigationObject.title = LocalizableString.alerts.localized
                navigationObject.subtitle = viewModel.device.displayName
            }
        }
    }
}

extension MultipleAlertsView {
    struct Alert {
        let type: CardWarningType
        let title: String
        let message: String
        let buttonTitle: String
        let buttonAction: VoidCallback
        let appearAction: VoidCallback?
    }
}

struct MultipleAlertsView_Previews: PreviewProvider {
    static var previews: some View {
        let mainVM = MainScreenViewModel.shared
        NavigationContainerView {
            MultipleAlertsView(viewModel: AlertsViewModel(device: .emptyDeviceDetails, mainVM: mainVM, followState: .init(deviceId: "123", relation: .owned)))
        }
    }
}
