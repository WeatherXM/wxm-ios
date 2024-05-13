//
//  BluetoothScanView.swift
//  PresentationLayer
//
//  Created by Manolis Katsifarakis on 29/9/22.
//

import DomainLayer
import SwiftUI
import Toolkit

struct BluetoothScanView: View {
    @EnvironmentObject var viewModel: ClaimDeviceViewModel
	
    private let didSelectDevice: (BTWXMDevice) -> Void
    /// Will change on `viewModel.toggleShowClaimSheet` changes.
    /// Used state to prevent unnecessary body calls and some animation issues with custom sheet dismissal
    @State private var showStatusSheet = false

    public init(didSelectDevice: @escaping (BTWXMDevice) -> Void) {
        self.didSelectDevice = didSelectDevice
    }

    var body: some View {
        VStack {
            mainContent
            if viewModel.isBluetoothReady {
                if viewModel.isScanning {
                    scanProgress
                } else {
                    scanButton
                }
            }
        }
        .background(Color(colorEnum: .layer1))
        .onChange(of: viewModel.selectedBluetoothDevice) { device in
            if let device = device {
                didSelectDevice(device)
            }
        }
        .onChange(of: viewModel.toggleShowClaimSheet) { _ in
            showStatusSheet = true
        }
        .onAppear {
            viewModel.enableBluetooth()
        }
        .customSheet(isPresented: $showStatusSheet) { controller in
            HeliumClaimingStatusView(
                dismiss: controller.dismiss,
                restartClaimFlow: {
                    controller.dismiss()
                }
            )
            .environmentObject(viewModel)
        }
    }

    @ViewBuilder
    var mainContent: some View {
        switch viewModel.bluetoothState {
            case .unknown:
                BluetoothMessageView(message: .empty)
            case .unsupported:
                BluetoothMessageView(message: .unsupported)
            case .unauthorized:
                BluetoothMessageView(message: .noAccess)
            case .poweredOff:
                BluetoothMessageView(message: .bluetoothOff)
            case .resetting, .poweredOn:
                if viewModel.devices.isEmpty {
                    if !viewModel.isScanning {
                        noDevicesFound
                    } else {
                        scanningForDevices
                    }
                } else {
                    if #available(iOS 16.0, *) {
                        deviceList.scrollContentBackground(.hidden)
                    } else {
                        deviceList
                    }
                }
        }
    }

    var scanningForDevices: some View {
        return VStack(alignment: .center) {
            Spacer()

            Image(asset: .bluetoothGray)
                .renderingMode(.template)
                .foregroundColor(Color(colorEnum: .darkGrey))
                .padding(.vertical)

            Text(LocalizableString.ClaimDevice.scanningForWXMDevices.localized)
                .font(.system(size: CGFloat(.mediumFontSize), weight: .bold))
                .foregroundColor(Color(colorEnum: .darkestBlue))

            Spacer()
        }
        .padding(.horizontal)
    }

    var noDevicesFound: some View {
        return VStack(alignment: .center) {
            Spacer()

            Image(asset: .wonderFace)
                .renderingMode(.template)
                .foregroundColor(Color(colorEnum: .darkGrey))
                .padding(.vertical)

            Text(LocalizableString.Bluetooth.noDevicesFoundTitle.localized)
                .font(.system(size: CGFloat(.mediumFontSize), weight: .bold))
                .foregroundColor(Color(colorEnum: .darkestBlue))
                .padding(.bottom)

            Text(LocalizableString.Bluetooth.noDevicesFoundText.localized)
                .font(.system(size: CGFloat(.normalFontSize)))
                .multilineTextAlignment(.center)
                .foregroundColor(Color(colorEnum: .text))

            Spacer()
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    var deviceList: some View {
        let list = List {
            ForEach(viewModel.devices) { device in
                let isLast = viewModel.devices.last?.identifier == device.identifier
                if #available(iOS 15.0, *) {
                    deviceRow(device, isLast: isLast)
                        .listRowSeparator(.hidden)
                } else {
                    deviceRow(device, isLast: isLast)
                }
            }
        }
        .listStyle(.plain)
        .background(Color(colorEnum: .layer1))
        .onAppear {
            // Required to remove default List separator and List background on older iOS versions.
            UITableView.appearance().separatorStyle = .none
            UITableView.appearance().backgroundColor = UIColor.clear
        }

        if #available(iOS 16.0, *) {
            list.scrollContentBackground(.hidden)
        } else {
            list
        }
    }

    var scanButton: some View {
        Button {
            WXMAnalytics.shared.trackEvent(.selectContent, parameters: [.contentType: .bleScanAgain])
            viewModel.startScanning()
        } label: {
            Label(
                LocalizableString.ClaimDevice.scanAgain.localized,
                image: AssetEnum.claimBluetoothButton.rawValue
            )
            .foregroundColor(Color(colorEnum: .primary))
        }
        .buttonStyle(WXMButtonStyle(fillColor: .layer1))
        .padding(.horizontal, CGFloat(.defaultSidePadding))
        .padding(.bottom, CGFloat(.defaultSidePadding))
    }

    @State private var scanProgressScale: CGFloat = 0

    var scanProgress: some View {
        Label(
            LocalizableString.ClaimDevice.scanningForWXMDevices.localized,
            image: AssetEnum.claimBluetoothButton.rawValue
        )
        .font(.system(size: CGFloat(.normalFontSize), weight: .bold))
        .foregroundColor(Color(colorEnum: .primary))
        .frame(maxWidth: .infinity)
        .frame(height: 50)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .style(withStroke: Color(colorEnum: .primary), lineWidth: 2, fill: Color(colorEnum: .layer1))

                RoundedRectangle(cornerRadius: 3)
                    .style(withStroke: .clear, lineWidth: 0, fill: Color(colorEnum: .lightestBlue))
                    .scaleEffect(CGSize(width: scanProgressScale, height: 1), anchor: .leading)
                    .padding(1)
            }
        )
        .padding(.horizontal, CGFloat(.defaultSidePadding))
        .padding(.bottom, CGFloat(.defaultSidePadding))
        .onAppear {
            scanProgressScale = 0
            withAnimation(.linear(duration: 5)) {
                scanProgressScale = 1
            }
        }
        .onAnimationCompleted(for: scanProgressScale) {
            viewModel.stopScanning()
        }
    }
}

private extension BluetoothScanView {
    private func deviceRow(_ device: BTWXMDevice, isLast: Bool) -> some View {
        let name = "\(device.name ?? "")"
        let isFetching = viewModel.pendingConnectionDevice == device
        return Button {
            if isFetching { return }
            viewModel.selectDevice(device)
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                Spacer()

                HStack(spacing: 0) {
                    if isFetching {
                        ProgressView()
                            .frame(width: 20, height: 20)
                    } else {
                        Image(asset: .claimHelium)
                            .renderingMode(.template)
                            .foregroundColor(Color(colorEnum: .text))
                    }

                    Text(LocalizableString.ClaimDevice.deviceHelium.localized)
                        .font(.system(size: CGFloat(.normalFontSize)))
                        .padding(.leading, 12)
                        .foregroundColor(Color(colorEnum: .text))

                    Spacer()
                }
                .padding(.horizontal)

                Text(LocalizableString.ClaimDevice.deviceId(name).localized)
                    .font(.system(size: CGFloat(.normalFontSize), weight: .bold))
                    .foregroundColor(Color(colorEnum: .primary))
                    .padding(.horizontal)
                    .padding(.top, 7)
                    .padding(.bottom, 0)
                Spacer()

                if !isLast {
                    WXMDivider()
                }
            }
        }
        .buttonStyle(WXMButtonStyle(
            fillColor: .clear,
            strokeColor: .clear
        ))
        .background(Color(colorEnum: .layer1))
        .listRowBackground(Color(colorEnum: .layer1))
    }
}
