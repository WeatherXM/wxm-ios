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
    let informationPaddingHorizontal: CGFloat = 1
    let informationPaddingBottom: CGFloat = 10

    var body: some View {
        ZStack {
            Color.black.opacity(backgroundOpacity)
            scanner
        }
    }

    var scanner: some View {
        VStack {
            Spacer()
            qrBox
            Spacer()
            scanningGuide
        }
    }

    var qrBox: some View {
        ZStack {
            Rectangle()
                .frame(width: qrSquareDimensions, height: qrSquareDimensions)
                .blendMode(.destinationOut)
            Rectangle()
                .fill(Color.red.opacity(lineOpacity))
                .frame(width: qrSquareDimensions, height: lineHeight)
        }
    }

    var scanningGuide: some View {
        Text(LocalizableString.scannerGuide.localized)
            .foregroundColor(Color(.white))
            .font(.system(size: CGFloat(.normalFontSize)))
            .padding(.horizontal, informationPaddingHorizontal)
            .padding(.bottom, informationPaddingBottom)
    }
}
