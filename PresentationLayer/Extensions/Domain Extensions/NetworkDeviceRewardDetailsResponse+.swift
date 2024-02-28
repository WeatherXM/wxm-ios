//
//  NetworkDeviceRewardDetailsResponse+.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 28/2/24.
//

import Foundation
import DomainLayer

extension NetworkDeviceRewardDetailsResponse {

}

extension NetworkDeviceRewardDetailsResponse.Annotation {
	var color: ColorEnum? {
		guard let score else {
			return nil
		}

		switch score {
			case 0..<10:
				return .error
			case 10..<95:
				return .warning
			case 95..<100:
				return .darkestBlue
			default:
				return nil
		}
	}

	var mainAnnotation: RewardAnnotation? {
		if let annotation = summary?.first(where: { $0.severity == .error }) {
			return annotation
		} else if let annotation = summary?.first(where: { $0.severity == .warning }) {
			return annotation
		} else if let annotation = summary?.first(where: { $0.severity == .info }) {
			return annotation
		}

		return nil
	}
}
