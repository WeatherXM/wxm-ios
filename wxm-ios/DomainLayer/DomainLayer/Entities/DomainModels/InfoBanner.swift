//
//  InfoBanner.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 25/9/24.
//

import Foundation

public struct InfoBanner: Equatable {
	public let id: String?
	public let title: String?
	public let message: String?
	public let buttonShow: Bool?
	public let actionLabel: String?
	public let url: String?
	public let dismissable: Bool?

	public init(id: String?,
				title: String?,
				message: String?,
				buttonShow: Bool?,
				actionLabel: String?,
				url: String?,
				dismissable: Bool?) {
		self.id = id
		self.title = title
		self.message = message
		self.buttonShow = buttonShow
		self.actionLabel = actionLabel
		self.url = url
		self.dismissable = dismissable
	}
}
