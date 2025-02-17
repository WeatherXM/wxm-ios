//
//  ShimmerEffectLoaderView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 19/6/23.
//

import SwiftUI

struct ShimmerEffectLoaderView: View {

    let duration: Double = 2.0
    @State private var startPoint: UnitPoint = UnitPoint(x: -3.0, y: 0.5)
    @State private var endPoint: UnitPoint = UnitPoint(x: 0.0, y: 0.5)

    var body: some View {
        Capsule()
            .fill(
                LinearGradient(gradient: Gradient(colors: [Color(colorEnum: .netStatsFabColor),
                                                           Color(.clear),
                                                           Color(colorEnum: .netStatsFabColor)]),
                               startPoint: startPoint,
                               endPoint: endPoint)
            )
            .frame(height: 4.0)            
            .safeAreaInset(edge: .top, content: {
                Color.clear
            })
            .onAppear {
                let baseAnimation = Animation.easeInOut(duration: duration)
                let repeated = baseAnimation.repeatForever(autoreverses: false)
                withAnimation(repeated) {
                    startPoint = UnitPoint(x: 1.0, y: 0.0)
                    endPoint = UnitPoint(x: 4.0, y: 0.0)
                }
            }
    }
}

struct ShimmerEffectLoader_Previews: PreviewProvider {
    static var previews: some View {
        ShimmerEffectLoaderView()
            .frame(height: 10.0)
    }
}
