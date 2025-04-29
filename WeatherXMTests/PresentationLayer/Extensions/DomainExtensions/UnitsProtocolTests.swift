//
//  UnitsProtocolTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 29/4/25.
//

import Testing
@testable import WeatherXM
import DomainLayer

struct UnitsProtocolTests {

	@Test
	func temperatureUnitsEnum() {
		#expect(TemperatureUnitsEnum.celsius.unit == UnitConstants.CELCIUS)
		#expect(TemperatureUnitsEnum.fahrenheit.unit == UnitConstants.FAHRENHEIT)
		#expect(TemperatureUnitsEnum.celsius.settingUnitFriendlyName == LocalizableString.Units.celsiusFriendlyName.localized)
		#expect(TemperatureUnitsEnum.fahrenheit.settingUnitFriendlyName == LocalizableString.Units.fahrenheitFriendlyName.localized)
	}

	@Test
	func precipitationUnitsEnum() {
		#expect(PrecipitationUnitsEnum.millimeters.unit == UnitConstants.MILLIMETERS)
		#expect(PrecipitationUnitsEnum.inches.unit == UnitConstants.INCHES)
		#expect(PrecipitationUnitsEnum.millimeters.settingUnitFriendlyName == LocalizableString.Units.millimetersFriendlyName.localized)
		#expect(PrecipitationUnitsEnum.inches.settingUnitFriendlyName == LocalizableString.Units.inchesFriendlyName.localized)
	}

	@Test
	func windSpeedUnitsEnum() {
		#expect(WindSpeedUnitsEnum.kilometersPerHour.unit == UnitConstants.KILOMETERS_PER_HOUR)
		#expect(WindSpeedUnitsEnum.milesPerHour.unit == UnitConstants.MILES_PER_HOUR)
		#expect(WindSpeedUnitsEnum.metersPerSecond.unit == UnitConstants.METERS_PER_SECOND)
		#expect(WindSpeedUnitsEnum.knots.unit == UnitConstants.KNOTS)
		#expect(WindSpeedUnitsEnum.beaufort.unit == UnitConstants.BEAUFORT)
		#expect(WindSpeedUnitsEnum.kilometersPerHour.settingUnitFriendlyName == LocalizableString.Units.kilometersPerHourFriendlyName.localized)
		#expect(WindSpeedUnitsEnum.milesPerHour.settingUnitFriendlyName == LocalizableString.Units.milesPerHourFriendlyName.localized)
		#expect(WindSpeedUnitsEnum.metersPerSecond.settingUnitFriendlyName == LocalizableString.Units.metersPerSecondFriendlyName.localized)
		#expect(WindSpeedUnitsEnum.knots.settingUnitFriendlyName == LocalizableString.Units.knotsFriendlyName.localized)
		#expect(WindSpeedUnitsEnum.beaufort.settingUnitFriendlyName == LocalizableString.Units.beaufortFriendlyName.localized)
	}

	@Test
	func windDirectionUnitsEnum() {
		#expect(WindDirectionUnitsEnum.cardinal.unit == UnitConstants.CARDINAL)
		#expect(WindDirectionUnitsEnum.degrees.unit == UnitConstants.DEGREES)
		#expect(WindDirectionUnitsEnum.cardinal.settingUnitFriendlyName == LocalizableString.Units.cardinalFriendlyName.localized)
		#expect(WindDirectionUnitsEnum.degrees.settingUnitFriendlyName == LocalizableString.Units.degreesFriendlyName.localized)
	}

	@Test
	func pressureUnitsEnum() {
		#expect(PressureUnitsEnum.hectopascal.unit == UnitConstants.HECTOPASCAL)
		#expect(PressureUnitsEnum.inchOfMercury.unit == UnitConstants.INCH_OF_MERCURY)
		#expect(PressureUnitsEnum.hectopascal.settingUnitFriendlyName == LocalizableString.Units.hectopascalFriendlyName.localized)
		#expect(PressureUnitsEnum.inchOfMercury.settingUnitFriendlyName == LocalizableString.Units.inchOfMercuryFriendlyName.localized)
	}
}
