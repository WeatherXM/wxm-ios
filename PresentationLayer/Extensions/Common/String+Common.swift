//
//  String+Common.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 13/10/23.
//

import Foundation

extension String {
	var attributedMarkdown: AttributedString? {
		let options = AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)
		return try? AttributedString(markdown: self, options: options)
	}

	func trimWhiteSpaces() -> String {
		return trimmingCharacters(in: .whitespaces)
	}

	func lastActiveTime() -> String {
		guard case let lastActiveDate = timestampToDate(),
			  lastActiveDate != .distantPast
		else {
			return ""
		}
		var relativeDate: String
		let currentDate = Date()
		let minutes = currentDate.minutes(from: lastActiveDate)

		let relativeDateFormatter = RelativeDateTimeFormatter()
		relativeDateFormatter.locale = Locale(identifier: "en_US_POSIX")
		relativeDateFormatter.unitsStyle = .short

		if minutes <= 1 {
			relativeDate = LocalizableString.justNow.localized
		} else {
			relativeDate = relativeDateFormatter.localizedString(for: lastActiveDate, relativeTo: currentDate)
		}
		return relativeDate
	}
}
