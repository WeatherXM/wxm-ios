//
//  UILabel.swift
//  PresentationLayer
//
//  Created by Manolis Katsifarakis on 6/10/22.
//

import SwiftUI

/**
 A `UILabel` as a SwiftUI `View`.
 Supports `NSAttributedString` which can act  as a polyfill for `AttributedString` (which is not available pre-iOS 15).
 By default it sets up the internal UILabel for word wrapping and infinite lines, but that can be changed via the `setupUILabel`
 callback.
 */
struct AttributedLabel: View {
    @Binding var attributedText: NSAttributedString
    var setupUILabel: ((UILabel) -> Void)?

    @State private var height: CGFloat = 0

    var body: some View {
        AttributedLabelInternal(
            attributedText: $attributedText,
            setupUILabel: setupUILabel,
            height: $height
        ).frame(height: height)
    }

    private struct AttributedLabelInternal: UIViewRepresentable {
        @Binding var attributedText: NSAttributedString
        var setupUILabel: ((UILabel) -> Void)?
        @Binding var height: CGFloat

        func makeUIView(context _: Context) -> UILabel {
            let label = UILabel()
            label.lineBreakMode = .byWordWrapping
            label.numberOfLines = 0
            label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            setupUILabel?(label)
            return label
        }

        func updateUIView(_ uiView: UILabel, context _: Context) {
            uiView.attributedText = attributedText
            let size = uiView.sizeThatFits(CGSize(width: uiView.bounds.width, height: CGFloat.greatestFiniteMagnitude))

            DispatchQueue.main.async {
                height = size.height
            }
        }
    }
}
