//
//  Date+.swift
//  PresentationLayer
//
//  Created by Danae Kikue Dimou on 3/6/22.
//

import Foundation

extension Date {

    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    var isTomorrow: Bool {
        Calendar.current.isDateInTomorrow(self)
    }

    var dayAfter: Date? {
        return Calendar.current.date(byAdding: .day, value: 1, to: self)
    }

    var start: Date {
        Calendar.current.startOfDay(for: self)
    }

    func isIn(range: ClosedRange<Date>) -> Bool {
        range.contains(self)
    }

    func isSameDay(with date: Date, calendar: Calendar = .current) -> Bool {
        calendar.isDate(self, inSameDayAs: date)
    }

    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }

    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }

    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date.start, to: self).minute ?? 0
    }

    func toCurrentTimezone() -> Date {
        let timeZoneDifference =
            TimeInterval(TimeZone.current.secondsFromGMT())
        return addingTimeInterval(timeZoneDifference)
    }

    func getFormattedDate() -> String {
        let calendar = NSCalendar.current
        let dateFormatter = DateFormatter()
        if calendar.isDateInToday(self) {
            dateFormatter.dateFormat = "'Today,' HH:mm"
        } else {
            dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        }
        return dateFormatter.string(from: self)
    }

    func getDateWithDateFormat(dateFormat: String = "HH:mm") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: self)
    }

    func getFormattedDate(format: String) -> String {
        let dateformat = DateFormatter()
        dateformat.locale = Locale(identifier: "en_us")
        dateformat.dateFormat = format
        return dateformat.string(from: self)
    }

    func getDayOfDate() -> String {
        let dayFormat = "EEEE"
        let dateformat = DateFormatter()
        dateformat.locale = Locale(identifier: "en_US_POSIX")
        dateformat.dateFormat = dayFormat
        return dateformat.string(from: self)
    }

    func getDayMonthOfDate() -> String {
        let dayMonthFormat = "dd/M"
        let dateformat = DateFormatter()
        dateformat.dateFormat = dayMonthFormat
        return dateformat.string(from: self)
    }

    func localizedDateString(dateStyle: DateFormatter.Style = .medium, timeStyle: DateFormatter.Style = .medium) -> String {
        let dateformatter = DateFormatter()
        dateformatter.dateStyle = dateStyle
        dateformatter.timeStyle = timeStyle
        let dateString = dateformatter.string(from: self)
        return dateString
    }
}

extension TimeInterval {
    static var minute: Self {
        60.0
    }

    static var hour: Self {
        60.0 * 60.0
    }
}
