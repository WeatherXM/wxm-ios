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
        VStack(spacing: 0) {
            text
            results
            #if targetEnvironment(simulator)
                debugButton
            #endif
        }
        .WXMCardStyle(backgroundColor: Color(colorEnum: .layer1), insideHorizontalPadding: 0.0, insideVerticalPadding: 0.0)
        .padding(.bottom)
        .padding(.horizontal, CGFloat(.defaultSidePadding))
        .onAppear {
            viewModel.reset()
        }
    }

    var text: some View {
        HStack {
            VStack(alignment: .leading, spacing: CGFloat(.smallSpacing)) {
                title
                description
            }

            Spacer()
        }
        .padding(CGFloat(.defaultSidePadding))
        .background(Color(colorEnum: .top))
    }

    var title: some View {
        Text(LocalizableString.ClaimDevice.selectDeviceTitle.localized)
            .font(.system(size: CGFloat(.titleFontSize), weight: .bold))
            .foregroundColor(Color(colorEnum: .text))
    }

    var description: some View {
        Text(LocalizableString.ClaimDevice.selectDeviceDescription.localized)
            .font(.system(size: CGFloat(.caption)))
            .foregroundColor(Color(colorEnum: .text))
    }

    var results: some View {
        BluetoothScanView { _ in
            transport.nextStep()
        }
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
        .background(Color(colorEnum: .layer1))
    }
}
