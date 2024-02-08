//
//  RebootStationView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 9/3/23.
//

import SwiftUI
import DomainLayer
import Toolkit

struct RebootStationView: View {
    @StateObject var viewModel: RebootStationViewModel
    @EnvironmentObject var navigationObject: NavigationObject
    @Environment(\.dismiss) private var dismiss
	private let mainVM: MainScreenViewModel = .shared

    var body: some View {
        ZStack {
            Color(colorEnum: .top)
                .ignoresSafeArea()
            HStack {
                Spacer()

                VStack {
                    Spacer()

                    switch viewModel.state {
                        case .reboot:
                            DeviceUpdatesLoadingView(title: LocalizableString.rebootingStation.localized,
                                                     subtitle: nil,
                                                     steps: viewModel.steps,
                                                     currentStepIndex: $viewModel.currentStepIndex,
                                                     progress: .constant(nil))
                        case let .failed(obj):
                            FailView(obj: obj)
                        case let .success(obj):
                            SuccessView(obj: obj)
                    }

                    Spacer()
                }
				.iPadMaxWidth()
                .animation(.easeIn, value: viewModel.state)

                Spacer()
            }
            .padding(.horizontal, CGFloat(.defaultSidePadding))
        }
        .onAppear {
            navigationObject.willDismissAction = { [weak viewModel] in
                viewModel?.navigationBackButtonTapped()
            }
            viewModel.mainVM = mainVM
            navigationObject.title = LocalizableString.deviceInfoStationReboot.localized

            Logger.shared.trackScreen(.rebootStation,
                                      parameters: [.itemId: .custom(viewModel.device.id ?? "")])
        }
        .onChange(of: viewModel.dismissToggle) { _ in
            dismiss()
        }
    }
}

struct RebootStationView_Previews: PreviewProvider {
    static var previews: some View {
        var device = DeviceDetails.emptyDeviceDetails
        device.profile = .helium

        return NavigationContainerView {
            RebootStationView(viewModel: RebootStationViewModel(device: device, useCase: nil))
        }
    }
}
