//
//  RewardAnnotation.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 8/2/24.
//

import Foundation

public struct RewardAnnotation: Codable, Equatable, Hashable {
	public let severity: Severity?
	public let group: Group?
	public let title: String?
	public let message: String?
	public let docUrl: String?

	enum CodingKeys: String, CodingKey {
		case severity = "severity_level"
		case group
		case title
		case message
		case docUrl = "doc_url"
	}

	public init(severity: Severity?, group: Group?, title: String?, message: String?, docUrl: String?) {
		self.severity = severity
		self.group = group
		self.title = title
		self.message = message
		self.docUrl = docUrl
	}

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.severity = try container.decodeIfPresent(RewardAnnotation.Severity.self, forKey: .severity)

		self.group = try container.decodeIfPresent(RewardAnnotation.Group.self, forKey: .group)
		self.title = try container.decodeIfPresent(String.self, forKey: .title)
		self.message = try container.decodeIfPresent(String.self, forKey: .message)
		self.docUrl = try container.decodeIfPresent(String.self, forKey: .docUrl)
	}
}

public extension RewardAnnotation {
	enum Severity: String, Codable {
		case info = "INFO"
		case warning = "WARNING"
		case error = "ERROR"
	}

	enum Group: Codable, Equatable, Hashable, RawRepresentable {
		public init?(rawValue: String) {
			switch rawValue {
				case "NO_WALLET":
					self = .noWallet
				case "LOCATION_NOT_VERIFIED":
					self = .locationNotVerified
				default:
					self = .unknown(rawValue)
			}
		}
		
		case noWallet
		case locationNotVerified
		case unknown(String)

		public var rawValue: String {
			switch self {
				case .noWallet:
					"NO_WALLET"
				case .locationNotVerified:
					"LOCATION_NOT_VERIFIED"
				case .unknown(let value):
					value
			}
		}
	}
}
