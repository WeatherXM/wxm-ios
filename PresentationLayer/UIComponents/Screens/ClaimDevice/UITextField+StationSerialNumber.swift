//
//  UITextField+StationSerialNumber.swift
//  PresentationLayer
//
//  Created by Manolis Katsifarakis on 19/12/22.
//

import UIKit

extension UITextField {
    private static let PLACEHOLDER_CHARACTER = " "
    private static let SEPARATOR_CHARACTER = ":"
    private static let DISALLOWED_CHARACTERS_REGEX = "[^0-9|A-F|a-f|:]"

    private static var textFieldAddTrailingCharacters = NSHashTable<UITextField>.weakObjects()
    var addTrailingCharacters: Bool {
		get {
			Self.textFieldAddTrailingCharacters.contains(self)
		}

        set {
            if newValue {
                Self.textFieldAddTrailingCharacters.add(self)
            } else {
                Self.textFieldAddTrailingCharacters.remove(self)
            }
        }
    }

    private static var textFieldPlaceholderCharacters = NSMapTable<UITextField, NSString>.weakToStrongObjects()
    var placeholderCharacter: NSString {
        get {
            Self.textFieldPlaceholderCharacters.object(forKey: self) ?? ""
        }
        set(value) {
            Self.textFieldPlaceholderCharacters.setObject(value, forKey: self)
        }
    }

    func focusOnFirstOccuranceOf(_ character: Character) {
        var index = 0
        for char in text ?? "" {
            if char == character {
                break
            }

            index += 1
        }

        if let position = position(from: beginningOfDocument, offset: index) {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.selectedTextRange = self.textRange(from: position, to: position)
            }
        }
    }

    /**
     This method optimizes the Serial Number editing experience, by providing a character mask and customizing
     text input and selection for this particular usecase.
     */
	func updateSerialNumberCharactersIn(nsRange: NSRange, for enteredString: String, validator: SNValidator) {
        if !enteredString.isEmpty, enteredString.matches(Self.DISALLOWED_CHARACTERS_REGEX) {
            return
        }

        let string = removeSeparators(enteredString)
        if !enteredString.isEmpty, string.isEmpty {
            return
        }

        var nsRange = adjustedNsRange(from: nsRange, string: string)

        let placeholderCharacter = placeholderCharacter as String
        let stringToReplace = string.isEmpty
            ? (addTrailingCharacters
                ? String(repeating: placeholderCharacter, count: nsRange.length)
                : String(repeating: placeholderCharacter, count: 0)
            )
            : string.uppercased()

        let text = removeSeparators(text ?? "")

        if nsRange.length < string.count {
            let maxLength = text.count - nsRange.location
            nsRange.length = min(string.count, maxLength)
        }

        if let range = Range(nsRange, in: text) {
            let newText = text.replacingCharacters(in: range, with: stringToReplace)
            let selectedTextRange = adjustedTextRange(from: selectedTextRange, separators: .remove)

            if addTrailingCharacters {
                self.text = Self.formatAsSerialNumber(newText, validator: validator)
            } else {
                self.text = Self.formatAsSerialNumber(newText, chars: 0, validator: validator)
            }

            if
                let selectedTextRange = selectedTextRange,
                let newPosition = position(
                    from: selectedTextRange.start,
                    offset: string.count > 0 ? string.count : -1
                ) ?? position(
                    from: selectedTextRange.start,
                    offset: 0
                )
            {
                self.selectedTextRange = adjustedTextRange(
                    from: textRange(from: newPosition, to: newPosition),
                    separators: .add
                )
            }
        }
    }

    static func formatAsSerialNumber(
        _ text: String,
        chars: Int? = nil,
        placeholder: String? = nil,
		validator: SNValidator) -> String {
			let maxLength = validator.serialNumberSegments * 2
			let charsToAdd = chars ?? maxLength - text.count
			if charsToAdd <= 0 {
				return String(
					text
						.prefix(maxLength)
						.unfoldSubSequences(limitedTo: 2)
						.joined(separator: Self.SEPARATOR_CHARACTER)
				)
			}

			let placeholder = placeholder ?? Self.PLACEHOLDER_CHARACTER
			return String(
				(text + String(repeating: placeholder, count: charsToAdd))
					.prefix(maxLength)
			)
			.unfoldSubSequences(limitedTo: 2)
			.joined(separator: Self.SEPARATOR_CHARACTER)
		}
}

private extension UITextField {
    enum SeparatorBehavior {
        case add
        case remove
    }

    func offsetWithSeparators(_ ofs: Int, separators: SeparatorBehavior) -> Int {
        let separatorCount = ofs / (separators == .add ? 2 : 3)
        if separators == .add {
            return ofs + separatorCount
        } else {
            return ofs - separatorCount
        }
    }

    func adjustedNsRange(from range: NSRange, string: String) -> NSRange {
        var offset = 0
        if string.isEmpty, range.length == 1 {
            // Special case when deleting a character after a separator.
            if (range.location + range.length) % 3 == 0 {
                offset = 1
            }
        }

        let location = max(0, offsetWithSeparators(range.location, separators: .remove) - offset)
        let end = max(0, offsetWithSeparators(range.location + range.length, separators: .remove))
        let adjusted = NSRange(location: location, length: max(0, end - location))
        return adjusted
    }

    func adjustedTextRange(
        from range: UITextRange?,
        separators: SeparatorBehavior
    ) -> UITextRange? {
        guard let range = range else {
            return nil
        }

        let startOffset = min(max(0, offsetWithSeparators(
            offset(from: beginningOfDocument, to: range.start),
            separators: separators
        )), (text ?? "").count)

        let endOffset = min(max(0, offsetWithSeparators(
            offset(from: beginningOfDocument, to: range.end),
            separators: separators
        )), (text ?? "").count)

        guard
            let startPosition = position(from: beginningOfDocument, offset: startOffset),
            let endPosition = position(from: beginningOfDocument, offset: endOffset)
        else {
            return nil
        }

        return textRange(
            from: startPosition,
            to: endPosition
        )
    }

    func removeSeparators(_ text: String) -> String {
        return text.replacingOccurrences(of: Self.SEPARATOR_CHARACTER, with: "")
    }
}

extension Collection {
    func unfoldSubSequences(limitedTo maxLength: Int) -> UnfoldSequence<SubSequence, Index> {
        sequence(state: startIndex) { start in
            guard start < endIndex else { return nil }
            let end = index(start, offsetBy: maxLength, limitedBy: endIndex) ?? endIndex
            defer { start = end }
            return self[start ..< end]
        }
    }
}
