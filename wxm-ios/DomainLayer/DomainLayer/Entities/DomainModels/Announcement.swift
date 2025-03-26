//
//  Announcement.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 20/3/25.
//

import Foundation

public struct Announcement: Equatable {
	public let id: String?
	public let title: String?
	public let message: String?
	public let actionLabel: String?
	public let actionUrl: String?
	public let actionShow: Bool?
	public let dismissable: Bool?

	public init(id: String?, title: String?, message: String?, actionLabel: String?, actionUrl: String?, actionShow: Bool?, dismissable: Bool?) {
		self.id = id
		self.title = title
		self.message = message
		self.actionLabel = actionLabel
		self.actionUrl = actionUrl
		self.actionShow = actionShow
		self.dismissable = dismissable
	}
}
