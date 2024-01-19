//
//  AttributedTextView.swift
//  PresentationLayer
//
//  Created by Manolis Katsifarakis on 23/11/22.
//

import SwiftUI

/**
 A `UITextView` as a SwiftUI `View`.
 Supports `NSAttributedString` which can act  as a polyfill for `AttributedString` (which is not available pre-iOS 15).
 Use `setupUITextView` to configure the underlying `UITextView`.
 callback.
 */
struct AttributedTextView: View {
    @Binding var attributedText: NSAttributedString
    var setupUITextView: ((UITextView) -> Void)?

    @State private var height: CGFloat = 0

    var body: some View {
        AttributedTextViewInternal(
            attributedText: $attributedText,
            setupUITextView: setupUITextView,
            height: $height
        ).frame(height: height)
    }

    private struct AttributedTextViewInternal: UIViewRepresentable {
        @Binding var attributedText: NSAttributedString
        var setupUITextView: ((UITextView) -> Void)?
        @Binding var height: CGFloat

        func makeUIView(context _: Context) -> UITextView {
            let textView = NonSelectableLinkSupportingTextView()
            textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            textView.isEditable = false
            textView.textContainerInset = .zero
            textView.textContainer.lineFragmentPadding = 0
            setupUITextView?(textView)
            return textView
        }

        func updateUIView(_ uiView: UITextView, context _: Context) {
            uiView.attributedText = attributedText
            DispatchQueue.main.async {
                height = uiView.contentSize.height
            }
        }
    }
}

private class NonSelectableLinkSupportingTextView: UITextView {
    override func point(inside point: CGPoint, with _: UIEvent?) -> Bool {
        guard
            let pos = closestPosition(to: point),
            let range = tokenizer.rangeEnclosingPosition(pos, with: .character, inDirection: .layout(.left))
        else {
            return false
        }

        let startIndex = offset(from: beginningOfDocument, to: range.start)
        return attributedText.attribute(.link, at: startIndex, effectiveRange: nil) != nil
    }
}
