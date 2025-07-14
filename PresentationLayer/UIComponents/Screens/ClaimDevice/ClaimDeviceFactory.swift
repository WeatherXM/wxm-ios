//
//  ClaimDeviceFactory.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 30/4/24.
//

import Foundation
import SwiftUI

enum ClaimDeviceStep: Identifiable {
	case beforeBegin(ClaimDeviceBeforeBeginViewModel)
	case begin(ClaimDeviceBeginViewModel)
	case serialNumber(ClaimDeviceSerialNumberViewModel)
	case manualSerialNumber(ManualSerialNumberViewModel)
	case location(ClaimDeviceLocationViewModel)
	case photoIntro(ClaimDevicePhotoIntroViewModel)
	case reset(ResetDeviceViewModel)
	case selectDevice(SelectDeviceViewModel)
	case setFrequency(ClaimDeviceSetFrequencyViewModel)

	var id: String {
		switch self {
			case .beforeBegin:
				"beforeBegin"
			case .begin:
				"begin"
			case .serialNumber:
				"serialNumber"
			case .manualSerialNumber(let viewModel):
				"manualSerialNumber-\(viewModel)"
			case .location:
				"location"
			case .photoIntro(let viewModel):
				"photoIntro-\(viewModel)"
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
			case .beforeBegin(let viewModel):
				ClaimDeviceBeforeBeginView(viewModel: viewModel)
			case .begin(let viewModel):
				ClaimDeviceBeginView(viewModel: viewModel)
			case .serialNumber(let viewModel):
				ClaimDeviceSerialNumberView(viewModel: viewModel)
			case .manualSerialNumber(let viewModel):
				ManualSerialNumberView(viewModel: viewModel)
			case .location(let viewModel):
				ClaimDeviceLocationView(viewModel: viewModel)
			case .photoIntro(let viewModel):
				ClaimDevicePhotoIntroView(viewModel: viewModel)
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
