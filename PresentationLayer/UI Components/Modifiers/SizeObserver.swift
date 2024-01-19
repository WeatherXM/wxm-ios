//
//  SizeObserver.swift
//  PresentationLayer
//
//  Created by Pantelis Giazitsis on 24/1/23.
//

import SwiftUI

/// A modifier to observe the size of the view
struct SizeObserver: ViewModifier {
    @Binding var size: CGSize
    @Binding var frame: CGRect

    public init(size: Binding<CGSize>, frame: Binding<CGRect> = .constant(.zero)) {
        _size = size
        _frame = frame
    }

    public func body(content: Content) -> some View {
        content
            .background(GeometryReader { geometry in
                ZStack {
                    updateFrame(frame: geometry.frame(in: .global))
                }
            })
    }

    @ViewBuilder
    func updateFrame(frame: CGRect) -> some View {
        Color.clear.preference(key: FramePreferenceKey.self, value: frame)
            .onPreferenceChange(FramePreferenceKey.self) { preferences in
                DispatchQueue.main.async {
                    if self.frame != preferences {
                        self.frame = preferences
                    }

                    if self.size != preferences.size {
                        self.size = preferences.size
                    }
                }
            }
    }

    private struct FramePreferenceKey: PreferenceKey {
        typealias Value = CGRect
        static var defaultValue: Value = .zero

        static func reduce(value _: inout Value, nextValue: () -> Value) {
            _ = nextValue()
        }
    }
}

public extension View {
    func sizeObserver(size: Binding<CGSize>, frame: Binding<CGRect> = .constant(.zero)) -> some View {
        modifier(SizeObserver(size: size, frame: frame))
    }
}
