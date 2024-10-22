//
//  SpinningLoaderView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 20/3/23.
//

import SwiftUI

struct SpinningLoaderView: View {
    static let dimensions: CGFloat = 150

    var body: some View {
        LottieView(animationCase: AnimationsEnums.loading.animationString,
                   loopMode: .loop)
		.frame(width: Self.dimensions,
			   height: Self.dimensions)
    }
}

struct SpinningLoaderView_Previews: PreviewProvider {
    static var previews: some View {
        SpinningLoaderView()
    }
}
