//
//  DBWeather+CoreDataProperties.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 11/4/23.
//
//

import Foundation
import CoreData
import DomainLayer


extension DBWeather {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBWeather> {
        return NSFetchRequest<DBWeather>(entityName: "DBWeather")
    }

    @NSManaged public var deviceId: String?
    @NSManaged public var timestamp: String?
    @NSManaged public var tz: String?
    @NSManaged public var dateString: String?
    @NSManaged public var temperature: Double
    @NSManaged public var temperatureMax: Double
    @NSManaged public var temperatureMin: Double
    @NSManaged public var humidity: Int16
    @NSManaged public var windSpeed: Double
    @NSManaged public var windGust: Double
    @NSManaged public var windDirection: Int16
    @NSManaged public var uvIndex: Int16
    @NSManaged public var precipitation: Double
    @NSManaged public var precipitationProbability: Double
    @NSManaged public var precipitationAccumulated: Double
    @NSManaged public var dewPoint: Double
    @NSManaged public var solarIrradiance: Double
    @NSManaged public var cloudCover: Double
    @NSManaged public var pressure: Double
    @NSManaged public var icon: String?
    @NSManaged public var feelsLike: Double
}

extension DBWeather: ManagedObjectToCodableConvertible {
    var toCodable: CurrentWeather? {
        CurrentWeather(timestamp: timestamp,
                       temperature: temperature,
                       temperatureMax: temperatureMax,
                       temperatureMin: temperatureMin,
                       humidity: Int(humidity),
                       windSpeed: windSpeed,
                       windGust: windGust,
                       windDirection: Int(windDirection),
                       uvIndex: Int(uvIndex),
                       precipitation: precipitation,
                       precipitationProbability: precipitationProbability,
                       precipitationAccumulated: precipitationAccumulated,
                       dewPoint: dewPoint,
                       solarIrradiance: solarIrradiance,
                       cloudCover: cloudCover,
                       pressure: pressure,
                       icon: icon,
                       feelsLike: feelsLike)
    }
}

extension CurrentWeather: CodableToManagedObjectConvertible {
    var toManagedObject: DBWeather? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let dbWeather = DBWeather(context: DatabaseService.shared.context)
        dbWeather.timestamp = timestamp
        dbWeather.temperature = temperature ?? .nan
        dbWeather.humidity = Int16(truncatingIfNeeded: humidity ?? -1)
        dbWeather.temperatureMax = temperatureMax ?? .nan
        dbWeather.temperatureMin = temperatureMin ?? .nan
        dbWeather.windSpeed = windSpeed ?? .nan
        dbWeather.windGust = windGust ?? .nan
        dbWeather.windDirection = Int16(truncatingIfNeeded: windDirection ?? -1)
        dbWeather.uvIndex = Int16(truncatingIfNeeded: uvIndex ?? -1)
        dbWeather.solarIrradiance = solarIrradiance ?? .nan
        dbWeather.dewPoint = dewPoint ?? .nan
        dbWeather.precipitation = precipitation ?? .nan
        dbWeather.pressure = pressure ?? .nan
        dbWeather.icon = icon
        dbWeather.precipitationProbability = precipitationProbability ?? .nan
        dbWeather.precipitationAccumulated = precipitationAccumulated ?? .nan
        dbWeather.cloudCover = cloudCover ?? .nan
        dbWeather.feelsLike = feelsLike ?? .nan

        return dbWeather
    }
}
