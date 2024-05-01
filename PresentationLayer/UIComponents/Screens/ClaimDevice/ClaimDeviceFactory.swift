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
	case serialNumber
	case location

	var id: String {
		switch self {
			case .begin:
				"begin"
			case .serialNumber:
				"serialNumber"
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
			case .serialNumber:
				VStack {
					Spacer()
					Text(verbatim: "Serial number")
					Spacer()
				}
			case .location:
				VStack {
					Spacer()
					Text(verbatim: "location")
					Spacer()
				}
		}
	}
}
