//
//  String+.swift
//  PresentationLayer
//

//  Created by Hristos Condrea on 30/5/22.
//

import Foundation
import SwiftUI
import Toolkit

extension Optional where Wrapped == String {
    /// If nil returns a much  earlier date
    /// - Returns: DistantPast constant
    func stringToDate() -> Date {
        guard let self else {
            return .distantPast
        }

        let dateFormatter = ISO8601DateFormatter()
        let date = dateFormatter.date(from: self) ?? Date()
        return date
    }
}

extension String {

	var toTimezone: TimeZone? {
		TimeZone(identifier: self)
	}

    var convertedDeviceIdentifier: String {
        replacingOccurrences(of: ":", with: "")
    }

	var lottieAnimation: AnimationsEnums {
		AnimationsEnums(rawValue: self) ?? .notAvailable
	}

    init(_ displayedLinksEnum: DisplayedLinks) {
        self.init(displayedLinksEnum.linkURL)
    }

    func stringToDate() -> Date {
        let dateFormatter = ISO8601DateFormatter()
        let date = dateFormatter.date(from: self) ?? Date()
        return date
    }

    func tokenRewardsTimestampToDate(deviceTimeZone: String) -> Date {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: deviceTimeZone)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        if let date = formatter.date(from: self) {
            return date
        } else {
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
            if let nextValidDate = formatter.date(from: self) {
                return nextValidDate
            } else {
                return Date()
            }
        }
    }

    func getAnimationString() -> String {
        return AnimationsEnums(rawValue: self)?.animationString ?? AnimationsEnums.notAvailable.animationString
    }

    func isTextEmpty() -> Bool {
        if trimWhiteSpaces().isEmpty {
            return true
        } else {
            return false
        }
    }

    func removeSpaces() -> String {
        replacingOccurrences(of: " ", with: "")
    }

    func containsSpaces() -> Bool {
        rangeOfCharacter(from: .whitespacesAndNewlines) != nil
    }

    func matches(_ regex: String) -> Bool {
        return range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
    }

    func isValidEmail() -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return (matches(emailRegex))
    }

    func newAddressValidation() -> TextFieldError? {
        let regex = "^0x[a-fA-F0-9]{40}$"
        if matches(regex) {
            return nil
        } else if isTextEmpty() {
            return .emptyField
        } else {
            return .invalidNewAddress
        }
    }

    func replaceColonOcurrancies() -> String {
        return replacingOccurrences(of: ":", with: "")
    }

    func getWeekDayAndDate() -> String {
        let date = timestampToDate()
        let dayFormatter = DateFormatter()
		dayFormatter.locale = .current
		dayFormatter.setLocalizedDateFormatFromTemplate("EEEE dd/MM")
        var str = dayFormatter.string(from: date)
		/// Because of localization, in some cases the system adds commas (,)
		/// So we have to remove them
		str = str.replacingOccurrences(of: ",", with: "")

		if date.isToday || date.isTomorrow {
			let formatter = DateFormatter()
			formatter.doesRelativeDateFormatting = true
			formatter.dateStyle = .medium
			let relativeStr = formatter.string(from: date)
			str = "\(relativeStr), \(str)"
		}

        return str
    }

    func getTimeForLatestDateWeatherDetail() -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateStyle = .none
        inputFormatter.timeStyle = .short

        let date = timestampToDate()
        return inputFormatter.string(from: date)
    }

    func firstIndex(substring: String) -> Index? {
        range(of: substring)?.lowerBound
    }

    /// Returns an AttributedString, with the passed text in bold and in passed color
    /// - Parameters:
    ///   - text: The text to highlight
    ///   - color: The highlighted text's color
    /// - Returns: An Attributed string
    func withHighlightedPart(text: String, color: Color) -> AttributedString? {
        var currentText = text

        var range = range(of: currentText, options: .caseInsensitive)
        while range == nil && !currentText.isEmpty {
            currentText.removeLast()
            range = self.range(of: currentText, options: .caseInsensitive)
        }

        if let range {
            let substring = self[range]
            var attributedString = replacingOccurrences(of: substring, with: "**\(substring)**").attributedMarkdown

            if let attributedStringRange = attributedString?.range(of: substring) {
                attributedString?[attributedStringRange].foregroundColor = color
            }

            return attributedString
        }

        return self.attributedMarkdown
    }
}
