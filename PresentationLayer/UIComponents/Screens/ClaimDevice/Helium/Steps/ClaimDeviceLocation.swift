//
//  ClaimDeviceLocation.swift
//  PresentationLayer
//
//  Created by Manolis Katsifarakis on 29/9/22.
//

import SwiftUI

struct ClaimDeviceLocation: View {
    @EnvironmentObject var viewModel: ClaimDeviceViewModel

    @State private var isImportantMessageClosed = false
    @State private var isShowingClaimSheet = false

    private let swinjectHelper: SwinjectInterface
    private let transport: StepsNavView.Transport

    public init(swinjectHelper: SwinjectInterface, transport: StepsNavView.Transport) {
        self.swinjectHelper = swinjectHelper
        self.transport = transport
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                mainView
                acknowledgementContainer
            }
        }
        .padding(.horizontal, CGFloat(.defaultSidePadding))
        .padding(.bottom)
        .animation(.default)
        .onAppear {
            DispatchQueue.main.async {
                viewModel.moveToDetectedLocation()
            }
        }
    }

    var title: some View {
        HStack {
            Text(LocalizableString.ClaimDevice.confirmLocationTitle.localized)
                .font(.system(size: CGFloat(.titleFontSize), weight: .bold))
                .padding(.bottom, 10)
                .foregroundColor(Color(colorEnum: .text))

            Spacer()
        }
    }

    var mainView: some View {
        return GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 0) {
                topText.zIndex(10)
                map
            }
            .padding(.bottom, isImportantMessageClosed ? 0 : -20)
            .WXMCardStyle(
                insideHorizontalPadding: 1,
                insideVerticalPadding: 1
            )
            .frame(height: geometry.size.height + 20, alignment: .top)
        }
    }

    var map: some View {
        ZStack {
            ClaimDeviceLocationMapView()
                .environmentObject(viewModel)
                .onAppear {
                    // Ensure that the coordinates will be set. When the map does not appear for the first
                    // time the selected coordinates will not be set again, causing the selected location
                    // to not be determined. That in turn, causes the default Helium frequency to not be
                    // auto-detected (since it is based on the selected location).
                    viewModel.selectedCoordinates = viewModel.selectedCoordinates
                }
        }
    }

    var topText: some View {
        VStack(alignment: .leading) {
            title
        }
        .WXMCardStyle()
    }

    var acknowledgeToggle: some View {
        return Toggle(
            LocalizableString.ClaimDevice.locationAcknowledgeText.localized,
            isOn: $viewModel.isLocationAcknowledged
        )
        .labelsHidden()
        .toggleStyle(WXMToggleStyle.Default)
    }

    var acknowledgeText: some View {
        Text(LocalizableString.ClaimDevice.locationAcknowledgeText.localized)
            .font(.system(size: CGFloat(.normalFontSize)))
            .foregroundColor(Color(colorEnum: .text))
            .lineSpacing(4)
            .padding(.bottom)
    }

    var acknowledgementContainer: some View {
        VStack {
            HStack(alignment: .top, spacing: CGFloat(.mediumSpacing)) {
                acknowledgeToggle
                acknowledgeText
            }

            bottomButtons
        }
        .WXMCardStyle()
    }

    var bottomButtons: some View {
        Button {
            guard viewModel.isSelectedLocationValid() else {
                viewModel.showInvalidLocationToast()
                return
            }

            if !transport.isLastStep() {
                transport.nextStep()
                return
            }

            viewModel.claimDevice()
            isShowingClaimSheet = true
        } label: {
            Text(LocalizableString.ClaimDevice.confirmLocationConfirmAndClaim.localized)
        }
        .disabled(!viewModel.isLocationAcknowledged)
        .buttonStyle(WXMButtonStyle.filled())
        .customSheet(
            isPresented: $isShowingClaimSheet,
            allowSwipeAndTapToDismiss: .constant(false),
            onDismiss: {
                viewModel.cancelClaim()
            }
        ) { controller in
            HeliumClaimingStatusView(
                dismiss: controller.dismiss,
                restartClaimFlow: {
                    viewModel.claimDevice()
                }
            )
            .environmentObject(viewModel)
        }
    }
}
