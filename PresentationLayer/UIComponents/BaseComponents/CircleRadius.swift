//
//  CircleRadius.swift
//  PresentationLayer
//
//  Created by danaekikue on 20/6/22.
//

import SwiftUI

struct CircleRadius: View {
    var isOptionActive: Bool
    let outerCircleWidth: CGFloat = 18
    let innerCircleWidth: CGFloat = 9
    let borderWidth: CGFloat = 2

    var body: some View {
        ZStack {
            Circle()
                .inset(by: 1)
                .stroke(Color(colorEnum: isOptionActive ? .primary : .text), lineWidth: borderWidth)
                .frame(width: outerCircleWidth, height: outerCircleWidth)
            if isOptionActive {
                Circle()
                    .fill(Color(colorEnum: .primary))
                    .frame(width: innerCircleWidth, height: innerCircleWidth)
            }
        }
    }
}
