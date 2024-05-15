//
//  ClaimDeviceFactory.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 30/4/24.
//

import Foundation
import SwiftUI

enum ClaimDeviceStep: Identifiable {

	case begin(ClaimDeviceBeginViewModel)
	case serialNumber(ClaimDeviceSerialNumberViewModel)
	case manualSerialNumber(ManualSerialNumberViewModel)
	case location

	var id: String {
		switch self {
			case .begin:
				"begin"
			case .serialNumber:
				"serialNumber"
			case .manualSerialNumber:
				"manualSerialNumber"
			case .location:
				"location"
		}
	}
}

// MARK: - Views

extension ClaimDeviceStep {
	@ViewBuilder
	var contentView: some View {
		switch self {
			case .begin(let viewModel):
				ClaimDeviceBeginView(viewModel: viewModel)
			case .serialNumber(let viewModel):
				ClaimDeviceSerialNumberView(viewModel: viewModel)
			case .manualSerialNumber(let viewModel):
				ManualSerialNumberView(viewModel: viewModel)
			case .location:
				VStack {
					Spacer()
					Text(verbatim: "location")
					Spacer()
				}
		}
	}
}
