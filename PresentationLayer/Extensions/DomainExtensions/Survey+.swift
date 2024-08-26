//
//  Survey+.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 26/8/24.
//

import Foundation
import DomainLayer
import Toolkit

extension Survey {
	func toAnnouncementConfiguration(actionTitle: String?, action: VoidCallback?, closeAction: VoidCallback?) -> AnnouncementCardView.Configuration? {
		guard let title, let message else {
			return nil
		}
		
		return .init(title: title, description: message, actionTitle: actionTitle, action: action, closeAction: closeAction)
	}
}
