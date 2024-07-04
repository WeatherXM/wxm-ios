//
//  QrScannerView.swift
//  PresentationLayer
//
//  Created by Danae Kikue Dimou on 10/6/22.
//

import SwiftUI

struct QrScannerView: View {
    let qrSquareDimensions: CGFloat = 300
    let backgroundOpacity: CGFloat = 0.5
    let lineOpacity: CGFloat = 0.4
    let lineHeight: CGFloat = 1

    var body: some View {
        ZStack {
            Color.black.opacity(backgroundOpacity)
				.ignoresSafeArea()
            scanner
        }
    }

	@ViewBuilder
    var scanner: some View {
		ZStack {
			qrBox

			VStack {
				Spacer()
				scanningGuide
			}
		}
    }

	@ViewBuilder
    var qrBox: some View {
		GeometryReader { proxy in
			ZStack {
				Rectangle()
					.frame(width: proxy.size.width / 2.0,
						   height: proxy.size.width / 2.0)
					.blendMode(.destinationOut)
				Rectangle()
					.fill(Color.red.opacity(lineOpacity))
					.frame(width: proxy.size.width / 2.0, height: lineHeight)
			}
			.position(x: proxy.size.width / 2.0, y: proxy.size.height / 2.0)
		}
    }

	@ViewBuilder
    var scanningGuide: some View {
        Text(LocalizableString.scannerGuide.localized)
			.multilineTextAlignment(.center)
            .foregroundColor(Color(.white))
            .font(.system(size: CGFloat(.mediumSidePadding)))
			.padding(CGFloat(.defaultSidePadding))
			.fixedSize(horizontal: false, vertical: true)
    }
}

#Preview {
	QrScannerView()
}
