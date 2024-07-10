//
//  Haptics.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 1/7/24.
//

import Foundation
import UIKit

enum Haptics {
	static func performSuccessHapticEffect() {
		let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
		notificationFeedbackGenerator.prepare()
		notificationFeedbackGenerator.notificationOccurred(.success)
	}

	static func performSelectionHapticEffect() {
		let notificationFeedbackGenerator = UISelectionFeedbackGenerator()
		notificationFeedbackGenerator.prepare()
		notificationFeedbackGenerator.selectionChanged()
	}
}
