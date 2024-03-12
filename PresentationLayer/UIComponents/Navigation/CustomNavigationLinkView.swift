//
//  CustomNavigationLinkView.swift
//  PresentationLayer
//
//  Created by Hristos Condrea on 20/5/22.
//

import SwiftUI

struct CustomNavigationLinkView<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        GeometryReader { _ in
            ZStack {
                Color(colorEnum: .bg).edgesIgnoringSafeArea(.vertical)
                content
                    .buttonStyle(GeneralButtonStyle())
            }

        }.ignoresSafeArea(.keyboard, edges: .all)
    }
}
