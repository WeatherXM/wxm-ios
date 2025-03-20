//
//  Announcement+.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 20/3/25.
//

import DomainLayer
import Toolkit

extension Announcement {
	func toAnnouncementConfiguration(buttonAction: VoidCallback?,
									 closeAction: VoidCallback?) -> AnnouncementCardView.Configuration {
		let configuration = AnnouncementCardView.Configuration(title: title ?? "",
															   description: message ?? "",
															   actionTitle: actionLabel,
															   action: buttonAction,
															   closeAction: closeAction)
		return configuration
	}
}
