//
//  DeviceAnnotation.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 2/11/23.
//

import Foundation

public struct DeviceAnnotations: Codable, Hashable, Equatable {
	public let qod: [DeviceAnnotation]?
	public let pol: [DeviceAnnotation]?
	public let rm: [DeviceAnnotation]?

	public init(qod: [DeviceAnnotation]?, pol: [DeviceAnnotation]?, rm: [DeviceAnnotation]?) {
		self.qod = qod
		self.pol = pol
		self.rm = rm
	}
}

public struct DeviceAnnotation: Codable, Hashable, Equatable {
	public let annotation: AnnotationType?
	public let ratio: Int?
	public let affects: [AffectedParameter]?

	public init(error: AnnotationType?, ratio: Int?, affects: [AffectedParameter]?) {
		self.annotation = error
		self.ratio = ratio
		self.affects = affects
	}

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.annotation = (try? container.decodeIfPresent(DeviceAnnotation.AnnotationType.self, forKey: .annotation)) ?? .unknown
		self.ratio = try container.decodeIfPresent(Int.self, forKey: .ratio)
		self.affects = try container.decodeIfPresent([DeviceAnnotation.AffectedParameter].self, forKey: .affects)
	}
}

public extension DeviceAnnotation {
	enum AnnotationType: String, Codable, CaseIterable {
		case obc = "OBC"
		case spikes = "SPIKES_INST"
		case unidentifiedSpike = "UNIDENTIFIED_SPIKE"
		case noMedian = "NO_MEDIAN"
		case noData = "NO_DATA"
		case shortConst = "SHORT_CONST"
		case longConst = "LONG_CONST"
		case frozenSensor = "FROZEN_SENSOR"
		case anomIncrease = "ANOMALOUS_INCREASE"
		case unidentifiedAnomalousChange = "UNIDENTIFIED_ANOMALOUS_CHANGE"
		case locationNotVerified = "LOCATION_NOT_VERIFIED"
		case noLocationData = "NO_LOCATION_DATA"
		case noWallet = "NO_WALLET"
		case cellCapacityReached = "CELL_CAPACITY_REACHED"
		case relocated = "RELOCATED"
		case polThresholdNotReached = "POL_THRESHOLD_NOT_REACHED"
		case qodThresholdNotReached = "QOD_THRESHOLD_NOT_REACHED"
		case unknown
	}

	struct AffectedParameter: Codable, Hashable, Equatable {
		public let ratio: Double?
		public let parameter: WeatherField?

		public init(ratio: Double?, parameter: WeatherField?) {
			self.ratio = ratio
			self.parameter = parameter
		}
	}
}
