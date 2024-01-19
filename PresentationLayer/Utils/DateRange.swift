//
//  DateRange.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 13/9/23.
//

import Foundation

struct DateRange {
    let epoch: Date
    let values: ClosedRange<Int>

    var range: ClosedRange<Date> {
        first!...last!
    }

    func getIndexOfDate(_ date: Date) -> Index? {
        firstIndex(where: { $0.isSameDay(with: date) })
    }

    func getFixedDate(from date: Date) -> Date? {
        guard let index = getIndexOfDate(date) else {
            return nil
        }

        return self[index]
    }

    func getPreviousDate(from date: Date) -> Date? {
        guard let index = getIndexOfDate(date), index > startIndex else {
            return nil
        }
        let previousIndex = self.index(before: index)
        if previousIndex < startIndex {
            return nil
        }

        return self[previousIndex]
    }

    func getNextDate(from date: Date) -> Date? {
        guard let index = getIndexOfDate(date) else {
            return nil
        }
        let nextIndex = self.index(after: index)
        if nextIndex == endIndex {
            return nil
        }
        return self[nextIndex]
    }

}

extension DateRange: Collection {
    typealias Index = ClosedRange<Int>.Index

    var startIndex: Index { self.values.startIndex }
    var endIndex: Index { self.values.endIndex }
    var count: Int { values.count }

    func index(after index: Index) -> Index { values.index(after: index) }

    subscript(index: Index) -> Date {
        Calendar.current.date(
            byAdding: .day,
            value: self.values[index],
            to: epoch
        )!
    }
}

extension DateRange: BidirectionalCollection {
    func index(before index: Index) -> Index {
        return values.index(before: index)
    }
}

extension DateRange: RandomAccessCollection { }
