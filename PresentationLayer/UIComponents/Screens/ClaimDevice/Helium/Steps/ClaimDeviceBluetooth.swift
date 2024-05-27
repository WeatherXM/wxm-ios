//
//  ClaimDeviceBluetooth.swift
//  PresentationLayer
//
//  Created by Manolis Katsifarakis on 30/9/22.
//

import SwiftUI

struct ClaimDeviceBluetooth: View {
    @EnvironmentObject private var viewModel: ClaimDeviceViewModel

    private let swinjectHelper: SwinjectInterface
    private let transport: StepsNavView.Transport

    public init(
        swinjectHelper: SwinjectInterface,
        transport: StepsNavView.Transport
    ) {
        self.swinjectHelper = swinjectHelper
        self.transport = transport
    }

    var body: some View {
		ZStack {
			Color(colorEnum: .newBG)
				.ignoresSafeArea()

			VStack(spacing: CGFloat(.mediumSpacing)) {
				text
				results
#if targetEnvironment(simulator)
				debugButton
#endif
			}
			.padding(.horizontal, CGFloat(.mediumSidePadding))
			.padding(.top, CGFloat(.largeSidePadding))
		}
        .onAppear {
            viewModel.reset()
        }
    }

    var text: some View {
        HStack {
            VStack(spacing: CGFloat(.minimumSpacing)) {
                title
                description
            }

            Spacer()
        }
    }

    var title: some View {
		HStack {
			Text(LocalizableString.ClaimDevice.selectDeviceTitle.localized)
				.font(.system(size: CGFloat(.titleFontSize), weight: .bold))
				.foregroundColor(Color(colorEnum: .darkestBlue))

			Spacer()
		}
    }

    var description: some View {
		HStack {
			Text(LocalizableString.ClaimDevice.selectDeviceDescription.localized)
				.font(.system(size: CGFloat(.normalFontSize)))
				.foregroundColor(Color(colorEnum: .newText))

			Spacer()
		}
    }

    var results: some View {
        BluetoothScanView { _ in
            transport.nextStep()
        }
		.clipped()
        .environmentObject(viewModel)
    }

    var debugButton: some View {
        Button {
            transport.nextStep()
        } label: {
            Text("DEBUG - Go to next")
        }
        .buttonStyle(WXMButtonStyle())
        .padding()
    }
}
