//
//  SelectDeviceView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 28/5/24.
//

import SwiftUI
import Toolkit

struct SelectDeviceView: View {
	@StateObject var viewModel: SelectDeviceViewModel

    var body: some View {
		ZStack {
			Color(colorEnum: .newBG)
				.ignoresSafeArea()

			VStack(spacing: CGFloat(.largeSpacing)) {
				title

				mainContent

				if viewModel.isBluetoothReady {
					
					if viewModel.isScanning {
						Text(verbatim: "scanProgress")
					} else {
						scanButton
					}
				}

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

	@ViewBuilder
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
	}

}

#Preview {
	SelectDeviceView(viewModel: ViewModelsFactory.getSelectDeviceViewModel {})
}
