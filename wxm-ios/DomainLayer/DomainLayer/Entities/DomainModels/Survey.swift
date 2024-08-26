//
//  Survey.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 26/8/24.
//

import Foundation

public struct Survey {
	public let id: String?
	public let title: String?
	public let message: String?
	public let actionLabel: String?
	public let url: String?

	public init(id: String?, title: String?, message: String?, actionLabel: String?, url: String?) {
		self.id = id
		self.title = title
		self.message = message
		self.actionLabel = actionLabel
		self.url = url
	}
}
