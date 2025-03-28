//
//  FoundationExtensions.swift
//  Toolkit
//
//  Created by Pantelis Giazitsis on 22/3/23.
//

import Foundation

public extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}

public extension Array {
    typealias Criteria = (Element, Element) -> Bool

    /// Sort the array by multiple criterias.
    /// - Parameter criterias: The criterias to be evaluated. eg. If the first expression is equal we go to the next one
    /// - Returns: The sorted array
    func sortedByCriteria(criterias: [Criteria]) -> Array {
        sorted { (lhs, rhs) in
            for criteria in criterias {
                if !criteria(lhs, rhs) && !criteria(rhs, lhs) {
                    continue
                }

                return criteria(lhs, rhs)
            }

            return false
        }
    }
}

public extension Array where Element: Hashable {
    /// Returns the array withou duplicates keeping the order
    var withNoDuplicates: Array {
        var set = Set<Element>()
        let uniques: [Element] = compactMap { element in
            guard !set.contains(element) else {
                return nil
            }
            set.insert(element)
            return element
        }
        
        return uniques
    }
	
	/// Removes elements while the condition is `true`. eg.
	/// [1, 4, 2, 0, 2, 1, 7] -> [4, 2, 0, 2, 1, 7]
	/// - Parameter predicate: The condition to evaluate
	/// - Returns: An array with the removed items
    mutating func remove(while predicate: (Element) -> Bool) -> Self {
        var arr: [Element] = []

        var element = self.first
        while element != nil, predicate(element!) {
            arr.append(removeFirst())
            element = self.first
        }

        return arr
    }

}

public extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

public extension Dictionary {

    /// Appends the contents of a dictionary to an other
    ///
    /// - Parameters:
    ///   - lhs: The dictionary to add the elements
    ///   - rhs: The dictionary to be added
    static func += (lhs: inout [Key: Value], rhs: [Key: Value]) {
        rhs.forEach({ lhs[$0] = $1 })
    }
}

public extension CaseIterable where Self: Equatable {
    var index: Self.AllCases.Index? {
        Self.index(for: self)
    }

    static func value(for index: Self.AllCases.Index) -> Self {
        Self.allCases[index]
    }

    static func index(for value: Self?) -> Self.AllCases.Index? {
        guard let value = value else {
            return nil
        }

        return Self.allCases.firstIndex(of: value)
    }
}

public extension Optional where Wrapped: Collection {
	var isNilOrEmpty: Bool {
		guard let self else {
			return true
		}

		return self.isEmpty
	}
}

public extension String {
	var walletAddressMaskString: String {
		maskString(offsetStart: 5, offsetEnd: 5, maskedCharactersToShow: 5)
	}

	func maskString(offsetStart: Int, offsetEnd: Int, maskedCharactersToShow: Int) -> String {
		let defaultOffsetStart = offsetStart
		let defaultOffsetEnd = offsetEnd
		let defaultMaskedCharactersToShow = maskedCharactersToShow
		let defaultMaskCharacter = "*"
		var addressToShow = ""
		var counter = 0
		var maskedCharacters = 0

		forEach { character in
			if counter <= defaultOffsetStart || counter > self.count - defaultOffsetEnd {
				addressToShow.append(character)
			} else if (maskedCharacters + 1) < defaultMaskedCharactersToShow {
				maskedCharacters += 1
				addressToShow += defaultMaskCharacter
			}
			counter += 1
		}
		return addressToShow
	}

	func matches(_ regex: String) -> Bool {
		return range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
	}

	var capitalizedSentence: String {
		let firstLetter = prefix(1).capitalized
		let remainingLetters = dropFirst()
		return firstLetter + remainingLetters
	}
	
	func semVersionCompare(_ otherVersion: String) -> ComparisonResult {
		self.compare(otherVersion, options: .numeric)
	}
}

public extension URL {
	var isHttp: Bool {
		self.scheme == "http" || self.scheme == "https"
	}

	subscript(queryParam: String) -> String? {
		guard let url = URLComponents(string: absoluteString) else {
			return nil
		}
		
		return url.queryItems?.first(where: { $0.name == queryParam })?.value
	}

	var queryItems: [String: String]? {
		guard let url = URLComponents(string: absoluteString) else {
			return nil
		}

		return url.queryItems?.reduce(into: [:]) { $0[$1.name] = $1.value }
	}

	func deleteFile() {
		try? FileManager.default.removeItem(at: self)
	}

	mutating func appendQueryItem(name: String, value: String?) {
		guard var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
			return
		}

		var queryItems = urlComponents.queryItems ??  []
		let queryItem = URLQueryItem(name: name, value: value)
		queryItems.append(queryItem)
		urlComponents.queryItems = queryItems

		self = urlComponents.url ?? self
	}
}

public extension FileManager {
	static var documentsDirectory: URL? {
		let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		return urls.first
	}

	static var tempDirectory: URL? {
		FileManager.default.temporaryDirectory		
	}
}

public extension Int {
	var toFloat: Float {
		Float(self)
	}
}

infix operator ~==
public extension CGSize {
	static func ~== (lhs: Self, rhs: Self) -> Bool {
		(lhs.width ~== rhs.width) && (lhs.height ~== rhs.height)
	}
}
