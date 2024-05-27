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

    private var swinjectHelper: SwinjectInterface
    public init(swinjectHelper: SwinjectInterface) {
        self.swinjectHelper = swinjectHelper

		_viewModel = StateObject(wrappedValue: ViewModelsFactory.getClaimDeviceViewModel())
    }

    var body: some View {
        return StepsNavView(
            title: LocalizableString.ClaimDevice.ws2000DeviceTitle.localized,
            steps: stepsAuto()
        )
        .onChange(of: viewModel.shouldExitClaimFlow) { didFinish in
            if didFinish {
                presentationMode.wrappedValue.dismiss()
            }
        }
        .onAppear {
            WXMAnalytics.shared.trackScreen(.claimHelium)
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
}
