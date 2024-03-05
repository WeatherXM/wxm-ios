//
//  AnimationsEnums.swift
//  PresentationLayer
//
//  Created by Danae Kikue Dimou on 3/6/22.
//

import Foundation

enum AnimationsEnums: String {
    case notAvailable = "not-available"
    case clearDay = "clear-day"
    case clearNight = "clear-night"
    case partlyCloudyDay = "partly-cloudy-day"
    case partlyCloudyNight = "partly-cloudy-night"
    case overcastDay = "overcast-day"
    case overcastNight = "overcast-night"
    case drizzle
    case rain
    case thunderstormsRain = "thunderstorms-rain"
    case snow
    case sleet
    case wind
    case fog
    case cloudy
    case success
    case fail
    case loading
    case loader
    case emptyDevices
    case emptyGeneric
	case rocket
	case rocketDark

    var animationString: String {
        switch self {
            case .emptyDevices:
                return "anim_empty_devices"
            case .notAvailable:
                return "anim_not_available"
            case .clearDay:
                return "anim_weather_clear_day"
            case .clearNight:
                return "anim_weather_clear_night"
            case .partlyCloudyDay:
                return "anim_weather_partly_cloudy_day"
            case .partlyCloudyNight:
                return "anim_weather_partly_cloudy_night"
            case .overcastDay:
                return "anim_weather_overcast_day"
            case .overcastNight:
                return "anim_weather_overcast_night"
            case .drizzle:
                return "anim_weather_drizzle"
            case .rain:
                return "anim_weather_rain"
            case .thunderstormsRain:
                return "anim_weather_thunderstorms_rain"
            case .snow:
                return "anim_weather_snow"
            case .sleet:
                return "anim_weather_sleet"
            case .wind:
                return "anim_weather_wind"
            case .fog:
                return "anim_weather_fog"
            case .cloudy:
                return "anim_weather_cloudy"
            case .success:
                return "anim_success"
            case .fail:
                return "anim_error"
            case .loading:
                return "anim_loading"
            case .loader:
                return "anim_loader"
            case .emptyGeneric:
                return "anim_empty_generic"
			case .rocket:
				return "anim_rocket"
			case .rocketDark:
				return "anim_rocket_dark"
        }
    }
}
