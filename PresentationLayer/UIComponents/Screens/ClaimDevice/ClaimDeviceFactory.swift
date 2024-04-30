//
//  ClaimDeviceFactory.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 30/4/24.
//

import Foundation
import SwiftUI

enum ClaimDeviceStep {
	case begin(ClaimDeviceBeginViewModel)
	case serialNumber
	case location
}

// MARK: - Views

extension ClaimDeviceStep {
	@ViewBuilder
	var contentView: some View {
		switch self {
			case .begin(let viewModel):
				ClaimDeviceBeginView(viewModel: viewModel)
			case .serialNumber:
				Text(verbatim: "Serial number")
			case .location:
				Text(verbatim: "location")
		}
	}
}
