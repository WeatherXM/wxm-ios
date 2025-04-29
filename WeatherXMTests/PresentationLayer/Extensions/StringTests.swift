//
//  StringTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 28/4/25.
//

import Testing
@testable import WeatherXM
import Toolkit

struct StringTests {

	@Test
	func toTimezone()  {
		var timezone = "Europe/Athens"
		#expect(timezone.toTimezone != nil)

		timezone = "UTC"
		#expect(timezone.toTimezone != nil)

		timezone = "WXM"
		#expect(timezone.toTimezone == nil)
	}

	@Test
	func convertedDeviceIdentifier() {
		var str = "24:12:"
		#expect(!str.convertedDeviceIdentifier.contains(":"))
		str = "241212"
		#expect(str.convertedDeviceIdentifier == str)
	}

	@Test
	func trimWhiteSpaces() throws {
		#expect("  Hello  ".trimWhiteSpaces() == "Hello")
		#expect("\nHello\n".trimWhiteSpaces() == "Hello")
		#expect("Hello".trimWhiteSpaces() == "Hello")
	}

	@Test
	func lastActiveTime() throws {
		let str = Date().toTimestamp().lastActiveTime()
		#expect(str == LocalizableString.justNow.localized)
	}

	@Test
	func isTextEmpty() throws {
		#expect("  ".isTextEmpty() == true)
		#expect("Hello".isTextEmpty() == false)
		#expect("\n".isTextEmpty() == true)
	}

	@Test
	func removeSpaces() throws {
		#expect("Hello World".removeSpaces() == "HelloWorld")
		#expect("  Hello  World  ".removeSpaces() == "HelloWorld")
	}

	@Test
	func containsSpaces() throws {
		#expect("Hello World".containsSpaces() == true)
		#expect("HelloWorld".containsSpaces() == false)
		#expect("  ".containsSpaces() == true)
	}

	@Test
	func validEmail() throws {
		#expect("hello@example.com".isValidEmail() == true)
		#expect("invalid-email".isValidEmail() == false)
	}

	@Test
	func testNewAddressValidation() throws {
		// Valid Ethereum address
		#expect("0x1234567890abcdef1234567890abcdef12345678".newAddressValidation() == nil)
		// Invalid: missing 0x prefix
		#expect("1234567890abcdef1234567890abcdef12345678".newAddressValidation() == .invalidNewAddress)
		// Invalid: too short
		#expect("0x1234".newAddressValidation() == .invalidNewAddress)
		// Invalid: contains non-hex characters
		#expect("0x1234567890abcdef1234567890abcdef1234567g".newAddressValidation() == .invalidNewAddress)
		// Empty string
		#expect("".newAddressValidation() == .emptyField)
		// Only spaces
		#expect("   ".newAddressValidation() == .emptyField)
	}

	@Test
	func replaceColonOccurrences() throws {
		#expect("12:34:56".replaceColonOcurrancies() == "123456")
		#expect("No colons here".replaceColonOcurrancies() == "No colons here")
	}
}
