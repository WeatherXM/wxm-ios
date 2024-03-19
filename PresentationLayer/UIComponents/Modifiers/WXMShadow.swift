//
//  WXMShadow.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 5/4/23.
//

import SwiftUI

struct WXMShadow: ViewModifier {
    func body(content: Content) -> some View {
        content
            .shadow(color: Color(.black).opacity(0.25),
                    radius: ShadowEnum.stationCard.radius,
                    x: ShadowEnum.stationCard.xVal,
                    y: ShadowEnum.stationCard.yVal)
    }
}

extension View {
    func wxmShadow() -> some View {
        modifier(WXMShadow())
    }
}
