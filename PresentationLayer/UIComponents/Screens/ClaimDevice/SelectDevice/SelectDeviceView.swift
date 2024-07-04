//
//  SelectDeviceView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 28/5/24.
//

import SwiftUI
import Toolkit
import DomainLayer

struct SelectDeviceView: View {
	@StateObject var viewModel: SelectDeviceViewModel

	@State private var scanProgressScale: CGFloat = 0.0

    var body: some View {
		ZStack {
			Color(colorEnum: .newBG)
				.ignoresSafeArea()

			VStack(spacing: CGFloat(.largeSpacing)) {
				title

				mainContent

				if viewModel.isBluetoothReady {
					scanButton
				}

#if targetEnvironment(simulator)
				debugButton
#endif
			}
			.padding(CGFloat(.mediumSidePadding))
		}
		.onAppear {
			viewModel.setup()
		}
    }
}

private extension SelectDeviceView {
	@ViewBuilder
	var title: some View {
		VStack(spacing: CGFloat(.mediumSpacing)) {
			HStack {
				Text(LocalizableString.ClaimDevice.selectDeviceTitle.localized)
					.font(.system(size: CGFloat(.smallTitleFontSize), weight: .bold))
					.foregroundStyle(Color(colorEnum: .darkestBlue))

				Spacer()
			}

			HStack {
				Text(LocalizableString.ClaimDevice.selectDeviceDescription.localized)
					.font(.system(size: CGFloat(.normalFontSize)))
					.foregroundColor(Color(colorEnum: .newText))

				Spacer()
			}
		}
	}

	@ViewBuilder
	var debugButton: some View {
		Button {
			viewModel.handleDebugButtonTap()
		} label: {
			Text(verbatim: "DEBUG - Go to next")
		}
		.buttonStyle(WXMButtonStyle())
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
					devicesList
				}
		}
	}

	@ViewBuilder
	var scanButton: some View {
		Button {
			WXMAnalytics.shared.trackEvent(.selectContent, parameters: [.contentType: .bleScanAgain])
			viewModel.startScanning()
		} label: {
			let title = viewModel.isScanning ? LocalizableString.ClaimDevice.scanningForWXMDevices.localized : LocalizableString.ClaimDevice.scanAgain.localized
			
			ZStack {
				if viewModel.isScanning {
					Color(colorEnum: .lightestBlue)
						.scaleEffect(CGSize(width: scanProgressScale, height: 1.0),
									 anchor: .leading)
						.onAppear {
							withAnimation(.easeIn(duration: viewModel.scanDuration)) {
								scanProgressScale = 1.0
							}
						}
				}

				Label(title,
					  image: AssetEnum.claimBluetoothButton.rawValue)
				.foregroundColor(Color(colorEnum: .primary))
			}
		}
		.buttonStyle(WXMButtonStyle())
		.onChange(of: viewModel.isScanning) { newValue in
			guard newValue else {
				return
			}

			scanProgressScale = 0.0
		}
	}

	@ViewBuilder
	var noDevicesFound: some View {
		VStack(alignment: .center) {
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
	var scanningForDevices: some View {
		VStack(alignment: .center) {
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

	@ViewBuilder
	var devicesList: some View {
		ScrollView(showsIndicators: false) {
			VStack(spacing: CGFloat(.smallToMediumSpacing)) {
				ForEach(viewModel.devices) { device in
					deviceRow(device)
				}
			}
		}
	}

	@ViewBuilder
	func deviceRow(_ device: BTWXMDevice) -> some View {
		let isConnecting = viewModel.deviceToConnect?.identifier == device.identifier
		Button {
			viewModel.handleDeviceTap(device)
		} label: {
			VStack(spacing: CGFloat(.smallToMediumSpacing)) {

				HStack(spacing: CGFloat(.smallSpacing)) {
						Image(asset: .claimHelium)
							.renderingMode(.template)
							.foregroundColor(Color(colorEnum: .text))
							.spinningLoader(show: .constant(isConnecting),
											lottieLoader: false,
											hideContent: true)
					
					Text(LocalizableString.ClaimDevice.deviceHelium.localized)
						.font(.system(size: CGFloat(.normalFontSize)))
						.foregroundColor(Color(colorEnum: .text))
					
					Spacer()
				}
				
				HStack {
					Text(LocalizableString.ClaimDevice.deviceId(device.name ?? "").localized)
						.font(.system(size: CGFloat(.normalFontSize), weight: .bold))
						.foregroundColor(Color(colorEnum: .primary))
					Spacer()
				}

				WXMDivider()
			}
		}
	}
}

#Preview {
	SelectDeviceView(viewModel: ViewModelsFactory.getSelectDeviceViewModel { _ in })
}
