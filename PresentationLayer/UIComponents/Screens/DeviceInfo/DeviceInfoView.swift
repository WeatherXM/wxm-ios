//
//  DeviceInfoView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 7/3/23.
//

import SwiftUI
import DomainLayer
import Toolkit

struct DeviceInfoView: View {

    @EnvironmentObject var navigationObject: NavigationObject
    @StateObject var viewModel: DeviceInfoViewModel

    var body: some View {
        ZStack {
            Color(colorEnum: .bg)
                .ignoresSafeArea()

            ZStack {
                TrackableScroller(showIndicators: false) { completion in
                    viewModel.refresh(completion: completion)
				} content: {
                    VStack(spacing: CGFloat(.defaultSpacing)) {
                        ForEach(0 ..< viewModel.sections.count, id: \.self) { index in
                            let rows = viewModel.sections[index]
                            VStack(spacing: CGFloat(.mediumSpacing)) {
                                ForEach(rows, id: \.title) { row in
                                    DeviceInfoRowView(row: row)
                                    if row != rows.last {
                                        WXMDivider()
                                    }
                                }
                            }
                            .WXMCardStyle()
                            .wxmShadow()
                        }

                        StationInfoView(sections: viewModel.infoSections,
                                        contactSupportTitle: viewModel.contactSupportButtonTitle,
										showShare: $viewModel.showShareDialog,
										shareText: viewModel.shareDialogText) {
                            viewModel.handleShareButtonTap()
                        } contactSupportAction: {
                            viewModel.handleContactSupportButtonTap()
                        }
                        .WXMCardStyle()
                        .wxmShadow()

						ForEach(0 ..< viewModel.bottomSections.count, id: \.self) { index in
							let rows = viewModel.bottomSections[index]
							VStack(spacing: CGFloat(.mediumSpacing)) {
								ForEach(rows, id: \.title) { row in
									DeviceInfoRowView(row: row)
									if row != rows.last {
										WXMDivider()
									}
								}
							}
							.WXMCardStyle()
							.wxmShadow()
						}
                    }
					.iPadMaxWidth()
                    .padding(CGFloat(.defaultSidePadding))
                }
            }
            .spinningLoader(show: $viewModel.isLoading, hideContent: true)            
        }
        .onAppear {
			navigationObject.title = LocalizableString.DeviceInfo.title.localized
            navigationObject.navigationBarColor = Color(colorEnum: .bg)
            WXMAnalytics.shared.trackScreen(.stationSettings)
        }
        .fullScreenCover(isPresented: $viewModel.showRebootStation) {
            NavigationContainerView {
                RebootStationView(viewModel: viewModel.rebootStationViewModel)
            }
        }
        .fullScreenCover(isPresented: $viewModel.showChangeFrequency) {
            NavigationContainerView {
                ChangeFrequencyView(viewModel: viewModel.changeFrequencyViewModel)
            }
        }
        .bottomSheet(show: $viewModel.showAccountConfirmation) {
            AccountConfirmationView(viewModel: viewModel.accountConfirmationViewModel)
				.padding(CGFloat(.defaultSidePadding))
        }
    }
}

struct DeviceInfoView_Previews: PreviewProvider {
    static var previews: some View {
        var device = DeviceDetails.mockDevice
		device.bundle = .mock(name: .h1)

        return NavigationContainerView {
            DeviceInfoView(viewModel: ViewModelsFactory.getDeviceInfoViewModel(device: device,
																			   followState: .init(deviceId: device.id!, relation: .owned)))
        }
    }
}
