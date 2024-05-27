//
//  ClaimDeviceLocation.swift
//  PresentationLayer
//
//  Created by Manolis Katsifarakis on 29/9/22.
//

import SwiftUI

struct ClaimDeviceLocation: View {
    @EnvironmentObject var viewModel: ClaimDeviceViewModel

    @State private var isShowingClaimSheet = false

    private let swinjectHelper: SwinjectInterface
    private let transport: StepsNavView.Transport

    public init(swinjectHelper: SwinjectInterface, transport: StepsNavView.Transport) {
        self.swinjectHelper = swinjectHelper
        self.transport = transport
    }

    var body: some View {
        ZStack {
			Color(colorEnum: .newBG)
				.ignoresSafeArea()

			VStack(spacing: CGFloat(.smallToMediumSpacing)) {
                mainView
                acknowledgementContainer
            }
			.padding(.horizontal, CGFloat(.mediumSidePadding))
			.padding(.top, CGFloat(.largeSidePadding))
        }
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
                .foregroundColor(Color(colorEnum: .darkestBlue))

            Spacer()
        }
    }

    var mainView: some View {
        return GeometryReader { geometry in
			VStack(alignment: .leading, spacing: CGFloat(.mediumSpacing)) {
				title

                map
					.cornerRadius(CGFloat(.cardCornerRadius))
            }
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
    }

    var acknowledgementContainer: some View {
		VStack(spacing: CGFloat(.smallToMediumSpacing)) {
            HStack(alignment: .top, spacing: CGFloat(.mediumSpacing)) {
                acknowledgeToggle
                acknowledgeText
            }

            bottomButtons
        }
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
