//
//  DateExtensionsTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 24/7/24.
//

import XCTest
@testable import Toolkit

final class DateExtensionsTests: XCTestCase {

    func testTwelveHourPeriodTime() {
		let date = Date.now.endOfDay
		let expectedResult = "11 pm"
		XCTAssert(date?.twelveHourPeriodTime == expectedResult, "The date string should be \(expectedResult)")
    }

	func testRelativeDayStringIfExists() {
		let today = Date.now
		let yesterday = today.dayBefore
		let tomorrow = today.dayAfter
		let twoDaysAgo = yesterday.dayBefore
		let twoDaysAfter = tomorrow?.dayAfter
		XCTAssertNotNil(tomorrow)
		XCTAssertNotNil(twoDaysAfter)

		XCTAssert(today.relativeDayStringIfExists() == "Today", "The relative string should be \"Today\"")
		XCTAssert(yesterday.relativeDayStringIfExists() == "Yesterday", "The relative string should be \"Yesterday\"")
		XCTAssert(tomorrow?.relativeDayStringIfExists() == "Tomorrow", "The relative string should be \"Tomorrow\"")
		XCTAssertNil(twoDaysAgo.relativeDayStringIfExists())
		XCTAssertNil(twoDaysAfter?.relativeDayStringIfExists())
	}

	func testGetHour() {
		let date = Date.now.set(hour: 2)
		XCTAssert(date?.getHour() == 2, "Hour shoud be 2")
	}

	func testToTimestamp() {
		var date = Date().set(hour: 3)
		date = date?.set(day: 5)
		date = date?.set(month: 5)
		date = date?.set(year: 2024)
		let expectedResult = "2024-05-05T03:00:00\(TimeZone.current.fomattedGMTOffset)"
		XCTAssert(date?.toTimestamp() == expectedResult, "Timestamp should be \(expectedResult)")
	}

	func testTransactionsDateFormat() {
		var date = Date().set(hour: 3)
		date = date?.set(day: 5)
		date = date?.set(month: 5)
		date = date?.set(year: 2024)

		let expectedResult = "May 05 2024"
		XCTAssert(date?.transactionsDateFormat() == expectedResult, "The transaction date should be \(expectedResult)")
	}

	func testDailyHourlySamples() {
		let date = Date().set(hour: 3)
		let samples = date?.dailyHourlySamples(timeZone: .current)
		XCTAssert(samples?.count == 21, "The samples count should be 21")
	}

	func testgetFormattedDate() {
		var date = Date().set(hour: 3)
		date = date?.set(day: 5)
		date = date?.set(month: 5)
		date = date?.set(year: 2024)
		let expectedResult = "2024-05-05"
		let formattedResult = date?.getFormattedDate(format: .onlyDate)
		XCTAssert(expectedResult == formattedResult, "The result should be \(expectedResult)")
	}

	func testGetFormattedDateToday() {
		var today = Date().set(hour: 12)
		let expectedResult = "today at 12:00 pm"
		let formattedResult = today?.getFormattedDate(format: .onlyDate, relativeFormat: true)
		XCTAssert(expectedResult == formattedResult, "The result should be \(expectedResult)")
	}

	func testGetFormattedDateWithTimezone() {
		var date = Date().set(hour: 3)
		date = date?.set(day: 5)
		date = date?.set(month: 5)
		date = date?.set(year: 2024)
		let expectedResult = "2024-05-05 (UTC)"
		let formattedResult = date?.getFormattedDate(format: .onlyDate, timezone: .gmt, showTimeZoneIndication: true)
		XCTAssert(expectedResult == formattedResult, "The result should be \(expectedResult)")
	}

}
