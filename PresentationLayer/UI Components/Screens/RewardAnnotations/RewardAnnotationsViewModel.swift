//
//  RewardAnnotationsViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 28/2/24.
//

import Foundation
import Combine
import DomainLayer
import SwiftUI
import Toolkit

class RewardAnnotationsViewModel: ObservableObject {
	let device: DeviceDetails
	let annotations: [RewardAnnotation]
	let followState: UserDeviceFollowState?
	let refDate: Date

	init(device: DeviceDetails, annotations: [RewardAnnotation], followState: UserDeviceFollowState?, refDate: Date) {
		self.device = device
		self.annotations = annotations.sorted { ($0.severity ?? .info) < ($1.severity ?? .info) }
		self.followState = followState
		self.refDate = refDate
	}

	func annotationActionButtonTile(for annotation: RewardAnnotation?) -> String? {
		annotation?.annotationActionButtonTile(with: followState)
	}

	func handleButtonTap(for error: RewardAnnotation) {
		Logger.shared.trackEvent(.userAction, parameters: [.actionName: .rewardDetailsError,
														   .itemId: .custom(error.group?.rawValue ?? "")])
		
		error.handleRewardAnnotationTap(with: device, followState: followState)
	}

}

extension RewardAnnotationsViewModel: HashableViewModel {
	func hash(into hasher: inout Hasher) {
		hasher.combine("\(device.id)-\(refDate.timeIntervalSince1970)")
	}
}
