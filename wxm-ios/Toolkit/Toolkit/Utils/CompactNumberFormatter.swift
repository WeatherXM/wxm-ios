//
//  CompactNumberFormatter.swift
//  Toolkit
//
//  Created by Pantelis Giazitsis on 13/6/23.
//

import Foundation

public class CompactNumberFormatter: Formatter {

    private lazy var numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.roundingMode = .halfDown
        return formatter
    }()

    public override func string(for obj: Any?) -> String? {

        if let value = obj as? Int {
            return converted(value: value)
        }

        if let value = obj as? any BinaryInteger {
            return converted(value: value)
        }

        if let value = obj as? any BinaryFloatingPoint {
            return converted(value: value)
        }

        // Extra case when the passed argument is comming from json decoding
        if let value = (obj as? NSNumber)?.intValue {
            return convert(value: value)
        }

        return nil
    }

    private func converted<T: BinaryInteger>(value: T) -> String? {
        convert(value: Int(value))
    }

    private func converted<T: BinaryFloatingPoint>(value: T) -> String? {
        convert(value: Int(value))
    }

    private func convert(value: Int) -> String? {
        let unit: Unit? = Unit(value: value)
        let divider = unit?.divider ?? 1
        let conventedValue = Double(value) / Double(divider)
        numberFormatter.positiveSuffix = unit?.description
        numberFormatter.minimumFractionDigits = unit?.minFractionDigits ?? 0
        numberFormatter.maximumFractionDigits = unit?.maxFractionDigits ?? 0
        return numberFormatter.string(from: NSNumber(value: conventedValue))
    }
}

private enum Unit: Int, CaseIterable, CustomStringConvertible {
    case noUnit = 1
    case thousand = 1000
    case million = 1000000
    case billion = 1000000000

    init?(value: Int) {
        guard let unit = Unit.allCases.first(where: { $0.range.contains(value) }) else {
            return nil
        }
        self = unit
    }

    var description: String {
        switch self {
            case .noUnit:
                return ""
            case .thousand:
                return "K"
            case .million:
                return "M"
            case .billion:
                return "B"
        }
    }

    var minFractionDigits: Int {
        0
    }

    var maxFractionDigits: Int {
        1
    }

    var range: Range<Int> {
        switch self {
            case .noUnit:
                return 0..<Self.thousand.rawValue
            case .thousand:
                return rawValue..<Self.million.rawValue
            case .million:
                return rawValue..<Self.billion.rawValue
            default:
                return rawValue..<Int.max
        }
    }

    var divider: Int {
        rawValue
    }
}
