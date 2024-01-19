//
//  Double+.swift
//  DomainLayer
//
//  Created by Lampros Zouloumis on 31/8/22.
//

extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
