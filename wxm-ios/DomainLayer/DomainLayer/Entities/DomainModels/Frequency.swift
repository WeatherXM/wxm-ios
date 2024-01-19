//
//  Frequency.swift
//  DomainLayer
//
//  Created by Manolis Katsifarakis on 26/11/22.
//

public enum Frequency: String, CaseIterable, Identifiable, Equatable, Codable {
    case EU868
    case US915
    case AU915
    case CN470
    case KR920
    case IN865
    case RU864
    case AS923_1
    case AS923_2
    case AS923_3
    case AS923_4
    public var id: String {
        return rawValue
    }
}

public extension Frequency {
    var heliumBand: UInt {
        switch self {
        case .EU868:
            return 5
        case .US915:
            return 8
        case .AU915:
            return 1
        case .CN470:
            return 2
        case .KR920:
            return 6
        case .IN865:
            return 7
        case .RU864:
            return 9
        case .AS923_1:
            return 10
        case .AS923_2:
            return 11
        case .AS923_3:
            return 12
        case .AS923_4:
            return 13
        }
    }
}
