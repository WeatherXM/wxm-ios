//
//  DeviceLocation+.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 31/5/24.
//

import DomainLayer

private typealias CountryCodeFrequency = [String: Frequency?]

extension DeviceLocation {
	func getFrequencyFromCurrentLocationCountry(from countries: [CountryInfo]?) -> Frequency {
		guard let countryCode = countryCode?.uppercased(),
			  let frequency = countryCodeFrequencies(from: countries)?.first(where: { $0.key.uppercased() == countryCode })?.value else {
			return .US915
		}
		
		return frequency
	}

	private func countryCodeFrequencies(from countries: [CountryInfo]?) -> CountryCodeFrequency? {
		let frequencies = countries?.reduce([String: Frequency?]()) { result, info in
			var result = result
			result[info.code] = Frequency(rawValue: info.heliumFrequency ?? "")
			return result
		}

		return frequencies
	}

}
