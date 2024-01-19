//
//  SpinningLoaderView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 20/3/23.
//

import SwiftUI

struct SpinningLoaderView: View {
    private let dimensions: CGFloat = 150

    var body: some View {
        LottieView(animationCase: AnimationsEnums.loading.animationString,
                   loopMode: .loop)
        .frame(width: dimensions,
               height: dimensions)
    }
}

struct SpinningLoaderView_Previews: PreviewProvider {
    static var previews: some View {
        SpinningLoaderView()
    }
}
