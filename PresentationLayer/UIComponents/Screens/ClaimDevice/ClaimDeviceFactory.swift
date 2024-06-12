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
	case location(ClaimDeviceLocationViewModel)
	case reset(ResetDeviceViewModel)
	case selectDevice(SelectDeviceViewModel)
	case setFrequency(ClaimDeviceSetFrequencyViewModel)

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
			case .reset:
				"reset"
			case .selectDevice:
				"selectDevice"
			case .setFrequency:
				"setFrequency"
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
			case .location(let viewModel):
				ClaimDeviceLocationView(viewModel: viewModel)
			case .reset(let viewModel):
				ResetDeviceView(viewModel: viewModel)
			case .selectDevice(let viewModel):
				SelectDeviceView(viewModel: viewModel)
			case .setFrequency(let viewModel):
				ClaimDeviceSetFrequencyView(viewModel: viewModel)
		}
	}
}

// MARK: - Helium Steps

enum HeliumSteps: Int, CaseIterable, CustomStringConvertible {
	case settingFrequency
	case rebooting
	case claiming

	var description: String {
		switch self {
			case .settingFrequency:
				return LocalizableString.ClaimDevice.stepSettingFrequency.localized
			case .rebooting:
				return LocalizableString.rebootingStation.localized
			case .claiming:
				return LocalizableString.ClaimDevice.stepClaiming.localized
		}
	}
}

