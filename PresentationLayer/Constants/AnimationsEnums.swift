//
//  AnimationsEnums.swift
//  PresentationLayer
//
//  Created by Danae Kikue Dimou on 3/6/22.
//

import Foundation

enum AnimationsEnums: String, CaseIterable {
	case notAvailable = "not-available"
	case clearDay = "clear-day"
	case clearNight = "clear-night"
	case partlyCloudyDay = "partly-cloudy-day"
	case partlyCloudyNight = "partly-cloudy-night"
	case overcast
	case overcastRain = "overcast-rain"
	case overcastSnow = "overcast-snow"
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
	case overcastDrizzle = "overcast-drizzle"
	case overcastLightSnow = "overcast-light-snow"
	case overcastSleet = "overcast-sleet"
	case hazeDay = "haze-day"
	case hazeNight = "haze-night"
	case extremeDay = "extreme-day"
	case extremeNight = "extreme-night"
	case extremeRain = "extreme-rain"
	case extremeSnow = "extreme-snow"
	case extremeDaySleet = "extreme-day-sleet"
	case extremeNightSleet = "extreme-night-sleet"
	case extremeDayRain = "extreme-day-rain"
	case extremeNightRain = "extreme-night-rain"
	case extremeDaySnow = "extreme-day-snow"
	case extremeNightSnow = "extreme-night-snow"
	case extremeDayDrizzle = "extreme-day-drizzle"
	case extremeNightDrizzle = "extreme-night-drizzle"
	case extremeDayLightSnow = "extreme-day-light-snow"
	case extremeNightLightSnow = "extreme-night-light-snow"
	case dustDay = "dust-day"
	case dustNight = "dust-night"
	case dustWind = "dust-wind"
	case thunderstormsOvercastRain = "thunderstorms-overcast-rain"
	case thunderstormsLightRain = "thunderstorms-light-rain"
	case thunderstormsExtremeRain = "thunderstorms-extreme-rain"
	case partlyCloudyDayDrizzle = "partly-cloudy-day-drizzle"
	case partlyCloudyNightDrizzle = "partly-cloudy-night-drizzle"
	case partlyCloudyDaySnow = "partly-cloudy-day-snow"
	case partlyCloudyNightSnow = "partly-cloudy-night-snow"
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
				return "empty_devices"
			case .notAvailable:
				return "not_available"
			case .clearDay:
				return "weather_clear-day"
			case .clearNight:
				return "weather_clear-night"
			case .partlyCloudyDay:
				return "weather_partly-cloudy-day"
			case .partlyCloudyNight:
				return "weather_partly-cloudy-night"
			case .overcastDay:
				return "weather_overcast-day"
			case .overcastNight:
				return "weather_overcast-night"
			case .thunderstormsOvercastRain:
				return "weather_thunderstorms-overcast-rain"
			case .success:
				return "success"
			case .fail:
				return "error"
			case .loading:
				return "loading"
			case .loader:
				return "loader"
			case .emptyGeneric:
				return "empty_generic"
			case .rocket:
				return "rocket"
			case .rocketDark:
				return "rocket_dark"
			case .overcast:
				return "weather_overcast"
			case .overcastRain:
				return "weather_overcast-rain"
			case .overcastSnow:
				return "weather_overcast-snow"
			case .overcastDrizzle:
				return "weather_overcast-drizzle"
			case .overcastLightSnow:
				return "weather_overcast-light-snow"
			case .overcastSleet:
				return "weather_overcast-sleet"
			case .hazeDay:
				return "weather_haze-day"
			case .hazeNight:
				return "weather_haze-night"
			case .extremeDay:
				return "weather_extreme-day"
			case .extremeNight:
				return "weather_extreme-night"
			case .extremeRain:
				return "weather_extreme-rain"
			case .extremeSnow:
				return "weather_extreme-snow"
			case .extremeDaySleet:
				return "weather_extreme-day-sleet"
			case .extremeNightSleet:
				return "weather_extreme-night-sleet"
			case .extremeDayRain:
				return "weather_extreme-day-rain"
			case .extremeNightRain:
				return "weather_extreme-night-rain"
			case .extremeDaySnow:
				return "weather_extreme-day-snow"
			case .extremeNightSnow:
				return "weather_extreme-night-snow"
			case .extremeDayDrizzle:
				return "weather_extreme-day-drizzle"
			case .extremeNightDrizzle:
				return "weather_extreme-night-drizzle"
			case .extremeDayLightSnow:
				return "weather_extreme-day-light-snow"
			case .extremeNightLightSnow:
				return "weather_extreme-night-light-snow"
			case .dustDay:
				return "weather_dust-day"
			case .dustNight:
				return "weather_dust-night"
			case .dustWind:
				return "weather_dust-wind"
			case .thunderstormsLightRain:
				return "weather_thunderstorms-light-rain"
			case .thunderstormsExtremeRain:
				return "weather_thunderstorms-extreme-rain"
			case .partlyCloudyDayDrizzle:
				return "weather_partly-cloudy-day-drizzle"
			case .partlyCloudyNightDrizzle:
				return "weather_partly-cloudy-night-drizzle"
			case .partlyCloudyDaySnow:
				return "weather_partly-cloudy-day-snow"
			case .partlyCloudyNightSnow:
				return "weather_partly-cloudy-night-snow"
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
		}
	}
}
