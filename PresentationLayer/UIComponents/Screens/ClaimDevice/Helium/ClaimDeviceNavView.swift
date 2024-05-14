//
//  ClaimDeviceNavView.swift
//  PresentationLayer
//
//  Created by Manolis Katsifarakis on 27/9/22.
//

import SwiftUI
import Toolkit

struct ClaimDeviceNavView: View {
    @StateObject var viewModel: ClaimDeviceViewModel

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    let claimViaBluetooth: Bool

    private var swinjectHelper: SwinjectInterface
    public init(swinjectHelper: SwinjectInterface, claimViaBluetooth: Bool) {
        self.swinjectHelper = swinjectHelper
        self.claimViaBluetooth = claimViaBluetooth
        
		_viewModel = StateObject(wrappedValue: ViewModelsFactory.getClaimDeviceViewModel())
    }

    var body: some View {
        return StepsNavView(
            title: claimViaBluetooth ? LocalizableString.ClaimDevice.ws2000DeviceTitle.localized : LocalizableString.ClaimDevice.ws1000DeviceTitle.localized,
            steps: claimViaBluetooth ? stepsAuto() : stepsManual()
        )
        .onChange(of: viewModel.shouldExitClaimFlow) { didFinish in
            if didFinish {
                presentationMode.wrappedValue.dismiss()
            }
        }
        .onAppear {
            viewModel.isM5 = !claimViaBluetooth
            WXMAnalytics.shared.trackScreen(claimViaBluetooth ? .claimHelium : .claimM5)
        }
    }
}

private extension ClaimDeviceNavView {
    private func stepsAuto() -> [StepsNavView.Step] {
        [
            StepsNavView.Step(title: LocalizableString.ClaimDevice.resetStepTitle.localized) { transport in
                AnyView(
                    ClaimDeviceReset(
                        swinjectHelper: swinjectHelper,
                        transport: transport
                    )
                    .environmentObject(viewModel)
                )
            },
            StepsNavView.Step(title: LocalizableString.ClaimDevice.bluetoothTitle.localized) { transport in
                AnyView(
                    ClaimDeviceBluetooth(
                        swinjectHelper: swinjectHelper,
                        transport: transport
                    )
                    .environmentObject(viewModel)
                )
            },
            StepsNavView.Step(title: LocalizableString.ClaimDevice.locationStepTitle.localized) { transport in
                AnyView(
                    ClaimDeviceLocation(
                        swinjectHelper: swinjectHelper,
                        transport: transport
                    )
                    .environmentObject(viewModel)
                )
            },
            StepsNavView.Step(title: LocalizableString.ClaimDevice.frequencyStepTitle.localized) { transport in
                AnyView(
                    ClaimDeviceFrequency(
                        swinjectHelper: swinjectHelper,
                        transport: transport
                    )
                    .environmentObject(viewModel)
                )
            }
        ]
    }

    private func stepsManual() -> [StepsNavView.Step] {
        [
            StepsNavView.Step(title: LocalizableString.ClaimDevice.connectionStepTitle.localized) { transport in
                AnyView(
                    ClaimDeviceConnection(
                        swinjectHelper: swinjectHelper,
                        transport: transport
                    )
                    .environmentObject(viewModel)
                )
            },
            StepsNavView.Step(title: LocalizableString.ClaimDevice.verifyStepTitle.localized) { transport in
                AnyView(
                    ClaimDeviceVerify(
                        swinjectHelper: swinjectHelper,
                        transport: transport
                    )
                    .environmentObject(viewModel)
                )
            },
            StepsNavView.Step(title: LocalizableString.ClaimDevice.locationStepTitle.localized) { transport in
                AnyView(
                    ClaimDeviceLocation(
                        swinjectHelper: swinjectHelper,
                        transport: transport
                    )
                    .environmentObject(viewModel)
                )
            }
        ]
    }
}
