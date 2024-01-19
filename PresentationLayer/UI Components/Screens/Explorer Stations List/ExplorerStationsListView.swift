//
//  ExplorerStationsListView.swift
//  PresentationLayer
//
//  Created by Lampros Zouloumis on 22/8/22.
//

import SwiftUI
import Toolkit

struct ExplorerStationsListView: View {
    @StateObject var viewModel: ExplorerStationsListViewModel
    @EnvironmentObject var navigationObject: NavigationObject
    
    var body: some View {
        ZStack {
            Color(colorEnum: .layer2)
                .ignoresSafeArea()

            VStack {
                TrackableScrollView {
                    VStack {
                        ForEach(viewModel.devices) { device in
                            WeatherStationCard(device: device,
                                               followState: viewModel.getFollowState(for: device),
                                               followAction: { viewModel.followButtonTapped(device: device) })
                                .onTapGesture {
                                    viewModel.navigateToDeviceDetails(device)
                                }
                        }
                    }
                    .padding(CGFloat(.defaultSpacing))
                }
                .spinningLoader(show: $viewModel.isLoadingDeviceList, hideContent: true)
                .fail(show: $viewModel.isDeviceListFailVisible, obj: viewModel.deviceListFailObject)
                .wxmAlert(show: $viewModel.showLoginAlert) {
                    WXMAlertView(show: $viewModel.showLoginAlert,
                                 configuration: viewModel.alertConfiguration!) {
                        Button {
                            viewModel.signupButtonTapped()
                        } label: {
                            HStack {
                                Text(LocalizableString.dontHaveAccount.localized)
                                    .font(.system(size: CGFloat(.normalFontSize), weight: .bold))
                                    .foregroundColor(Color(colorEnum: .text))

                                Text(LocalizableString.signUp.localized.uppercased())
                                    .font(.system(size: CGFloat(.normalFontSize)))
                                    .foregroundColor(Color(colorEnum: .primary))
                            }
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            navigationObject.title = LocalizableString.NetStats.weatherStations.localized
            navigationObject.navigationBarColor = Color(colorEnum: .layer2)

            Logger.shared.trackScreen(.explorerCellScreen,
                                      parameters: [.itemId: .custom(viewModel.cellIndex)])
        }
        .onChange(of: viewModel.address) { newValue in
            navigationObject.subtitle = newValue ?? ""
        }
    }
}
