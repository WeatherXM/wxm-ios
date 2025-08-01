//
//  LocalizableString+Weather.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 1/8/25.
//

import Foundation

extension LocalizableString {
	enum Weather {
		case clear
		case clearFewLowClouds
		case partlyCloudy
		case clearButHazy
		case foggy
		case mostlyCloudy
		case overcast
		case overcastRain
		case overcastSnow
		case overcastHeavyRain
		case overcastHeavySnow
		case rainThunderstormsLikely
		case lightRainThunderstormsLikely
		case heavyRainThunderstormsLikely
		case mixedWithShowers
		case mixedWithSnowShowers
		case overcastLightRain
		case overcastLightSnow
		case overcastMixtureSnowRain
	}
}

extension LocalizableString.Weather: WXMLocalizable {
	var localized: String {
		let localized = NSLocalizedString(self.key, comment: "")
		return localized
	}

	var key: String {
		switch self {
			case .clear:
				"weather_clear"
			case .clearFewLowClouds:
				"weather_clear_few_low_clouds"
			case .partlyCloudy:
				"weather_partly_cloudy"
			case .clearButHazy:
				"weather_clear_but_hazy"
			case .foggy:
				"weather_foggy"
			case .mostlyCloudy:
				"weather_mostly_cloudy"
			case .overcast:
				"weather_overcast"
			case .overcastRain:
				"weather_overcast_rain"
			case .overcastSnow:
				"weather_overcast_snow"
			case .overcastHeavyRain:
				"weather_overcast_heavy_rain"
			case .overcastHeavySnow:
				"weather_overcast_heavy_snow"
			case .rainThunderstormsLikely:
				"weather_rain_thunderstorms_likely"
			case .lightRainThunderstormsLikely:
				"weather_light_rain_thunderstorms_likely"
			case .heavyRainThunderstormsLikely:
				"weather_heavy_rain_thunderstorms_likely"
			case .mixedWithShowers:
				"weather_mixed_with_showers"
			case .mixedWithSnowShowers:
				"weather_mixed_with_snow_showers"
			case .overcastLightRain:
				"weather_overcast_light_rain"
			case .overcastLightSnow:
				"weather_overcast_light_snow"
			case .overcastMixtureSnowRain:
				"weather_overcast_mixture_snow_rain"
		}
	}
}
