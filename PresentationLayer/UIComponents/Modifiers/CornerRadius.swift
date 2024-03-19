//
//  CornerRadius.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 3/3/23.
//

import Foundation
import SwiftUI

private struct CornerRadius: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( CornerRadius(radius: radius, corners: corners) )
    }
}
