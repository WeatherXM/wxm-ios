//
//  DateExtension.swift
//  Toolkit
//
//  Created by Pantelis Giazitsis on 11/4/23.
//

import Foundation

public extension Date {

    enum DateFormat: String {
        case timestamp = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        case onlyDate = "yyyy-MM-dd"
        case twelveHoursTime = "h a"
        case monthLiteralDayYear = "MMM dd, yyyy"
        case monthLiteralDayYearShort = "MMM dd y"
        case monthLiteralDay = "MMM d"
		case fullMonthLiteralDay = "MMMM d"
		case monthLiteralDayTime = "MMM d, HH:mm"
        case dayFullLiteral = "EEEE"
        case dayShortLiteralDayMonth = "E dd, MMM yy"
		case dayShortLiteralMonthDay = "E, MMM d"
        case fullDateTime = "MM/dd/yyyy, HH:mm"
    }

	var isYesterday: Bool {
		Calendar.current.isDateInYesterday(self)
	}

    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    var isTomorrow: Bool {
        Calendar.current.isDateInTomorrow(self)
    }

    var dayAfter: Date? {
        return Calendar.current.date(byAdding: .day, value: 1, to: self)
    }

    var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }


	var startOfHour: Date? {
		guard let date = Calendar.current.date(bySetting: .minute, value: 0, of: self) else {
			return nil
		}
	
		return Calendar.current.date(bySetting: .second, value: 0, of: date)
	}

    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }

    var month: Int {
        return Calendar.current.component(.month, from: self)
    }

    func startOfDay(timeZone: TimeZone = .current) -> Date {
        let identifier = Calendar.current.identifier
        var calendar = Calendar(identifier: identifier)
        calendar.timeZone = timeZone

        return calendar.startOfDay(for: self)
    }

	func endOfDay(timeZone: TimeZone = .current) -> Date? {
		let identifier = Calendar.current.identifier
		var calendar = Calendar(identifier: identifier)
		calendar.timeZone = timeZone

		return calendar.date(bySettingHour: 23, minute: 59, second: 59, of: self)
	}

	var middleOfDay: Date? {
		Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)
	}

    var endOfDay: Date? {
        Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: self)
    }

    var twelveHourPeriodTime: String {
        getFormattedDate(format: .twelveHoursTime)
    }

	func getWeekDay(_ style: FormatStyle.Symbol.Weekday = .abbreviated) -> String {
		formatted(Date.FormatStyle().weekday(style))
	}
	
	func relativeDayStringIfExists(timezone: TimeZone = .current) -> String? {
		guard self.isToday || self.isYesterday || self.isTomorrow else {
			return nil
		}

		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = .current
		dateFormatter.dateStyle = .medium
		dateFormatter.doesRelativeDateFormatting = true
		dateFormatter.locale = Locale(identifier: "en_US_POSIX")

		return dateFormatter.string(from: self)
	}

	func getHour(with timeZone: TimeZone = .current) -> Int? {
		let identifier = Calendar.current.identifier
		var calendar = Calendar(identifier: identifier)
		calendar.timeZone = timeZone
		return calendar.component(.hour, from: self)
	}

	func setHour(_ hour: Int) -> Date? {
		Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: self)
	}

    func toTimestamp(with timeZone: TimeZone = .current) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = DateFormat.timestamp.rawValue
        dateformat.locale = Locale(identifier: "en_US_POSIX")
        dateformat.timeZone = timeZone
        return dateformat.string(from: self)
    }

    func isIn(range: ClosedRange<Date>) -> Bool {
        range.contains(self)
    }

    func isSameDay(with date: Date, calendar: Calendar = .current) -> Bool {
        calendar.isDate(self, inSameDayAs: date)
    }

	func hours(from date: Date) -> Int {
		return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
	}

    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }

    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }

    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date.startOfDay(), to: self).day ?? 0
    }

    func toTimeZone(_ timeZone: TimeZone = .current) -> Date {
        let timeZoneDifference = TimeInterval(timeZone.secondsFromGMT() - TimeZone.current.secondsFromGMT())
        return addingTimeInterval(timeZoneDifference)
    }

    func transactionsDateFormat(timeZone: TimeZone = .current) -> String {
        let dateFormatter = DateFormatter()
		dateFormatter.timeZone = timeZone
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = DateFormat.monthLiteralDayYearShort.rawValue
        return dateFormatter.string(from: self)
    }

    func transactionsTimeFormat(timeZone: TimeZone = .current) -> String {
        let dateFormatter = DateFormatter()
		dateFormatter.timeZone = timeZone
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: self)
    }

	func getFormattedDate(format: DateFormat, relativeFormat: Bool = false, timezone: TimeZone? = nil, showTimeZoneIndication: Bool = false) -> String {
        let dateFormatter = DateFormatter()
		dateFormatter.timeZone = timezone

		let calendar = NSCalendar.current
		let isTodayOrYesterday = calendar.isDateInToday(self) || calendar.isDateInYesterday(self)
		if relativeFormat, isTodayOrYesterday {
			dateFormatter.timeStyle = .short
			dateFormatter.dateStyle = .medium
			dateFormatter.doesRelativeDateFormatting = true
		} else {
			dateFormatter.dateFormat = format.rawValue
		}
        
		dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
		var dateString = dateFormatter.string(from: self).lowercased()
		
		if showTimeZoneIndication, var timeZoneIdentifier = timezone?.identifier.uppercased() {
			if timeZoneIdentifier == TimeZone.UTCTimezone?.identifier {
				timeZoneIdentifier = "UTC"
			}
			dateString += " (\(timeZoneIdentifier))"
		}

		return dateString
    }

    func getDateStringRepresentation() -> String {
        let calendar = NSCalendar.current
        let dateFormatter = DateFormatter()
        if calendar.isDateInToday(self) || calendar.isDateInYesterday(self) {
            dateFormatter.timeStyle = .none
            dateFormatter.dateStyle = .medium
            dateFormatter.doesRelativeDateFormatting = true
        } else {
            dateFormatter.dateFormat = DateFormat.dayShortLiteralDayMonth.rawValue
        }
        return dateFormatter.string(from: self)
    }

    func localizedDateString(dateStyle: DateFormatter.Style = .medium, timeStyle: DateFormatter.Style = .medium) -> String {
        let dateformatter = DateFormatter()
        dateformatter.locale = Locale(identifier: "en_US_POSIX")
        dateformatter.dateStyle = dateStyle
        dateformatter.timeStyle = timeStyle
        let dateString = dateformatter.string(from: self)
        return dateString
    }
	
	/// Generates hourly samples starting from this date until the end of the current day
	/// - Parameter timeZone: The needed timezone
	/// - Returns: An array of dates with one hour diff
    func dailyHourlySamples(timeZone: TimeZone) -> [Date] {
		guard let start = self.startOfHour, let end = self.endOfDay(timeZone: timeZone) else {
			return []
		}

		let remainingHours = end.hours(from: start)
		let dates = (0...remainingHours).map { start.advanced(by: TimeInterval($0) * TimeInterval.hour) }
        return dates
    }

    func getFormattedDateOffsetByMonths(_ offsetMonths: Int) -> String {
        Calendar.current.date(byAdding: .month, value: offsetMonths, to: self)?.getFormattedDate(format: .onlyDate) ?? ""
    }

    func getFormattedDateOffsetByDays(_ offsetdays: Int) -> String {
        Calendar.current.date(byAdding: .day, value: offsetdays, to: self)?.getFormattedDate(format: .onlyDate) ?? ""
    }

    func advancedByDays(days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: self)!
    }

	func advancedByHours(hours: Int) -> Date {
		Calendar.current.date(byAdding: .hour, value: hours, to: self)!
	}
}

public extension TimeInterval {
    static var minute: Self {
        60.0
    }

    static var hour: Self {
        60.0 * 60.0
    }
}

public extension String {
    func timestampToDate(timeZone: TimeZone = .current) -> Date {
        let dateFormatter = ISO8601DateFormatter()
        let date = dateFormatter.date(from: self)?.toTimeZone(timeZone)
        return date ?? .distantPast
    }
	
	/// Get date from string with format "yyyy-MM-dd"
	/// - Returns: The `Date` object, nil if something went wrong
	func onlyDateStringToDate() -> Date? {
		let dateFromatter = DateFormatter()
		dateFromatter.dateFormat = Date.DateFormat.onlyDate.rawValue
		return dateFromatter.date(from: self)
	}
}

public extension TimeZone {
	var hoursOffsetString: String {
		let seconds = secondsFromGMT()
		let hours = seconds/3600
		let formatter = NumberFormatter()
		formatter.positivePrefix = "+"

		return "UTC\(formatter.string(for: hours) ?? "-")"
	}

	var isUTC: Bool {
		secondsFromGMT() == 0
	}

	static var UTCTimezone: TimeZone? {
		if #available(iOS 16, *) {
			.gmt
		} else {
			// Fallback on earlier versions
			TimeZone(abbreviation: "UTC")
		}
	}
}
