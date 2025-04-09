//
//  RewardAnnotationsViewModelTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 4/4/25.
//

import Testing
import DomainLayer
@testable import WeatherXM

@Suite(.serialized)
@MainActor
struct RewardAnnotationsViewModelTests {
	let viewModel: RewardAnnotationsViewModel
	let device: DeviceDetails
	let annotations: [RewardAnnotation]
	let followState: UserDeviceFollowState?
	let refDate: Date

	init() {
		device = DeviceDetails.mockDevice
		let docUrl = "https://example.com"
		annotations = [
			RewardAnnotation(severity: .info, group: .noWallet, title: "Info", message: "Info message", docUrl: docUrl),
			RewardAnnotation(severity: .warning, group: .locationNotVerified, title: "Warning", message: "Warning message", docUrl: docUrl),
			RewardAnnotation(severity: .error, group: .noLocationData, title: "Error", message: "Error message", docUrl: docUrl)
		]
		followState = nil
		refDate = Date()
		viewModel = .init(device: device,
						  annotations: annotations,
						  followState: followState,
						  refDate: refDate)
	}

	@Test func annotationActionButtonTile() {
		annotations.forEach { annotation in
			let title = viewModel.annotationActionButtonTile(for: annotation)
			#expect(title != nil)
			switch annotation.group {
				case .noWallet:
					#expect(title == LocalizableString.RewardDetails.readMore.localized)
				case .locationNotVerified:
					#expect(title == LocalizableString.RewardDetails.readMore.localized)
				default:
					#expect(title == LocalizableString.RewardDetails.readMore.localized)
			}
		}
	}
}
