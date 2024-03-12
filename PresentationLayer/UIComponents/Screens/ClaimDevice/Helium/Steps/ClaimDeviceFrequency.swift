//
//  ClaimDeviceFrequency.swift
//  PresentationLayer
//
//  Created by Manolis Katsifarakis on 28/11/22.
//

import DomainLayer
import SwiftUI

struct ClaimDeviceFrequency: View {
    @EnvironmentObject var viewModel: ClaimDeviceViewModel

    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>

    @State private var isImportantMessageClosed = false
    @State private var isShowingClaimSheet = false

    private let swinjectHelper: SwinjectInterface
    private let transport: StepsNavView.Transport

    public init(swinjectHelper: SwinjectInterface, transport: StepsNavView.Transport) {
        self.swinjectHelper = swinjectHelper
        self.transport = transport
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SelectFrequencyView(selectedFrequency: $viewModel.selectedFrequency,
                                isFrequencyAcknowledged: $viewModel.isFrequencyAcknowledged,
                                country: viewModel.selectedLocation?.country,
                                didSelectFrequencyFromLocation: viewModel.didSelectFrequencyFromLocation,
                                preSelectedFrequency: viewModel.preSelectedFrequency)

            bottomButtons
        }
        .WXMCardStyle()
        .padding(.horizontal, CGFloat(.defaultSidePadding))
        .padding(.bottom)
        .onChange(of: viewModel.selectedLocation) { _ in
            // This ensures that the frequency will be updated even if the map
            // from the (previous) location screen has not yet settled scrolling.
            // This can happen due to scrolling interia, when the user makes a very fast
            // gesture and immediately leaves the location screen before map scrolling
            // has stopped.
            viewModel.updateFrequencyFromCurrentLocationCountry()
        }
        .onAppear {
            viewModel.updateFrequencyFromCurrentLocationCountry()
        }
        .alert(isPresented: $viewModel.errorSettingFrequency) {
            frequencyErrorAlert
        }
    }

    var frequencyErrorAlert: Alert {
        Alert(
            title: Text(LocalizableString.SelectFrequency.settingFailedTitle.localized),
            message: Text(LocalizableString.SelectFrequency.settingFailedText.localized),
            primaryButton: .default(Text(LocalizableString.SelectFrequency.tryAgainButton.localized)) {
                viewModel.errorSettingFrequency = false
            },
            secondaryButton: .cancel(Text(LocalizableString.SelectFrequency.quitClaimingButton.localized)) {
                presentationMode.wrappedValue.dismiss()
            }
        )
    }

    var bottomButtons: some View {
        Button {
            viewModel.setFrequencyAndClaimSelectedDevice()
            isShowingClaimSheet = true
        } label: {
            Text(LocalizableString.ClaimDevice.confirmLocationConfirmAndClaim.localized)
        }
        .disabled(!viewModel.isFrequencyAcknowledged)
        .buttonStyle(WXMButtonStyle.filled())
        .customSheet(
            isPresented: $isShowingClaimSheet,
            allowSwipeAndTapToDismiss: .constant(false),
            onDismiss: {
                viewModel.cancelClaim()
            }
        ) { controller in
            HeliumClaimingStatusView(
                dismiss: {
                    viewModel.cancelClaim()
                    controller.dismiss()
                },
                restartClaimFlow: {
                    viewModel.setFrequencyAndClaimSelectedDevice()
                }
            )
            .environmentObject(viewModel)
        }
    }
}
