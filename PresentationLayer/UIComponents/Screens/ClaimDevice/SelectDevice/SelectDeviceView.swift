//
//  SelectDeviceView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 28/5/24.
//

import SwiftUI

struct SelectDeviceView: View {
	@StateObject var viewModel: SelectDeviceViewModel

    var body: some View {
		ZStack {
			Color(colorEnum: .newBG)
				.ignoresSafeArea()

			VStack(spacing: CGFloat(.largeSpacing)) {
				title

				mainContent
				
#if targetEnvironment(simulator)
				debugButton
#endif
			}
			.padding(.horizontal, CGFloat(.mediumSidePadding))
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
				Text(verbatim: "Resetting")
//				if viewModel.devices.isEmpty {
//					if !viewModel.isScanning {
//						noDevicesFound
//					} else {
//						scanningForDevices
//					}
//				} else {
//					if #available(iOS 16.0, *) {
//						deviceList.scrollContentBackground(.hidden)
//					} else {
//						deviceList
//					}
//				}
		}
	}

}

#Preview {
	SelectDeviceView(viewModel: .init())
}
