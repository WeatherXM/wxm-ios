//
//  QrScannerView.swift
//  PresentationLayer
//
//  Created by Danae Kikue Dimou on 10/6/22.
//

import SwiftUI

struct ScannerOverlayView: View {
	var layout: Layout = .square
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
				let frameSize = frameSize(containerSize: proxy.size)
				Rectangle()
					.frame(width: frameSize.width,
						   height: frameSize.height)
					.blendMode(.destinationOut)
				Rectangle()
					.fill(Color.red.opacity(lineOpacity))
					.frame(width: frameSize.width, height: lineHeight)
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

	func frameSize(containerSize: CGSize) -> CGSize {
		switch layout {
			case .rectangle:
				CGSize(width: 3.0 * containerSize.width / 4.0, height: containerSize.width / 4.0)
			case .square:
				CGSize(width: containerSize.width / 2.0, height: containerSize.width / 2.0)
		}
	}
}

extension ScannerOverlayView {
	enum Layout {
		case rectangle
		case square
	}
}

#Preview {
	ScannerOverlayView(layout: .rectangle)
}
