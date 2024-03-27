//
//  WXMRemoteImageView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 26/3/24.
//

import SwiftUI
import NukeUI

struct WXMRemoteImageView: View {
	let imageUrl: String?

    var body: some View {
		ZStack {
			Color(colorEnum: .remoteImagePlaceholder)

			if let imageUrl {
				LazyImage(url: URL(string: imageUrl)) { state in
					if let image = state.image {
						image.resizable()
							.transition(AnyTransition.opacity.animation(.easeIn(duration: 0.2)))
					}
				}
			}
		}
    }
}

#Preview {
    WXMRemoteImageView(imageUrl: "https://weatherxm.s3.eu-west-1.amazonaws.com/resources/public/BetaRewardsBoostImg.png")
}
