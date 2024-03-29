//
//  CustomSegmentView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 3/3/23.
//

import SwiftUI

struct CustomSegmentView: View {
    private let segments: [String]
    @Binding private var selectedIndex: Int
    private let style: Style
    private let selectorPadding: CGFloat = 20.0
    private let cornerRadius: CGFloat = 60.0
    @State private var sizes: [SizeWrapper]
    @State private var containerSize: CGSize = .zero

    init(options: [String], selectedIndex: Binding<Int>, style: Style = .normal) {
        self.style = style
        self.segments = options
        self._selectedIndex = selectedIndex
        self.sizes = (0..<segments.count).map { _ in SizeWrapper() }
    }

    var body: some View {
        switch style {
            case .normal:
                normalStyle
            case .plain:
                plainStyle
        }
    }
}

extension CustomSegmentView {
    enum Style {
        case normal
        case plain
    }
}

// MARK: - Viewbuilders
private extension CustomSegmentView {
    @ViewBuilder
    var normalStyle: some View {
        ZStack {
            HStack {
                let size = selectorSizeForIndex(selectedIndex)
                Color(colorEnum: .top)
                    .offset(x: selectorOffsetForIndex(selectedIndex))
                    .frame(width: size.width,
                           height: size.height)
                Spacer(minLength: 0.0)
            }
        }
        .background {
            Color(colorEnum: .primary)
        }
        .mask {
            segmentsView
        }
        .background {
            selectorView
        }
        .sizeObserver(size: $containerSize)
        .overlay {
            HStack(spacing: 0.0) {
                ForEach(0 ..< segments.count, id: \.self) { index in
                    Button {
                        selectedIndex = index
                    } label: {
                        Color.clear
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .frame(width: sizes[index].size.width, height: sizes[index].size.height)

                    let islast = index == segments.count - 1
                    if !islast {
                        Spacer(minLength: 0.0)
                    }
                }
            }
            .padding(.horizontal, selectorPadding)
        }
        .padding(2.0)
        .strokeBorder(color: Color(colorEnum: .primary), lineWidth: 1.0, radius: cornerRadius)
        .animation(.easeIn(duration: 0.3), value: selectedIndex)
    }

    @ViewBuilder
    var plainStyle: some View {
        VStack(spacing: 0.0) {
            segmentsView
                .foregroundColor(Color(colorEnum: .darkGrey))

            HStack {
                let size = selectorSizeForIndex(selectedIndex)
                Capsule()
                    .foregroundColor(Color(colorEnum: .primary))
                    .frame(width: size.width,
                           height: 2.0)
                    .offset(x: selectorOffsetForIndex(selectedIndex))

                Spacer()
            }
        }
        .sizeObserver(size: $containerSize)
        .animation(.easeIn(duration: 0.3), value: selectedIndex)
    }

    @ViewBuilder
    var segmentsView: some View {
        HStack(spacing: 0.0) {
            ForEach(0 ..< segments.count, id: \.self) { index in
                let segment = segments[index]
                Button {
                    selectedIndex = index
                } label: {
                    Text(segment)
                        .font(.system(size: CGFloat(.normalFontSize), weight: .medium))
                        .if(selectedIndex == index, transform: { view in
                            view.foregroundColor(Color(colorEnum: .primary))
                        })
						.padding(.vertical, CGFloat(.smallSidePadding))
                        .sizeObserver(size: $sizes[index].size)
                }

                let islast = segments.last == segment
                if !islast {
                    Spacer(minLength: 0.0)
                }
            }
        }
        .padding(.horizontal, selectorPadding)
    }

    @ViewBuilder
    var selectorView: some View {
        ZStack {
            Color(colorEnum: .blueTint)

            let size = selectorSizeForIndex(selectedIndex)
            HStack {
                Color(colorEnum: .primary)
                    .cornerRadius(cornerRadius)
                    .frame(width: size.width, height: size.height)
                    .offset(x: selectorOffsetForIndex(selectedIndex))
                Spacer(minLength: 0.0)
            }
        }
        .cornerRadius(cornerRadius)
    }
}

// MARK: - Helpers
private extension CustomSegmentView {

    var spacerWidth: CGFloat {
        let spacersCount = max(0, segments.count - 1)
        guard spacersCount > 0 else {
            return 0.0
        }

        let elementsTotalWidth = sizes.reduce(0.0) { $0 + $1.size.width }
        let width = containerSize.width - 2.0 * selectorPadding - elementsTotalWidth

        return width / CGFloat(spacersCount)
    }

    func selectorSizeForIndex(_ index: Int) -> CGSize {
        let segmentSize = sizes[index].size
        let sidePadding = style == .normal ? 2.0 * selectorPadding : 0.0
        let width = segmentSize.width + sidePadding
        let height = segmentSize.height
        return CGSize(width: width, height: height)
    }

    func selectorOffsetForIndex(_ index: Int) -> CGFloat {
        let spacerWidth = spacerWidth
        let floatIndex = CGFloat(index)
        let elementsWidth = index > 0 ? (0..<index).reduce(0.0) { $0 + sizes[$1].size.width } : 0.0
        let spacersWidth: CGFloat = (max(0, floatIndex) * spacerWidth)
        let extraPadding = style == .normal ? 0.0 : selectorPadding
        return elementsWidth + spacersWidth + extraPadding
    }
}

struct CustomSegmentView_Previews: PreviewProvider {
    static var previews: some View {
        CustomSegmentView(options: ["Measurements", "Forecast", "Rewards"], selectedIndex: .constant(1))
    }
}

struct CustomSegmentView_Four_Elements_Previews: PreviewProvider {
    static var previews: some View {
        CustomSegmentView(options: ["Measurements", "Forecast", "Rewards", "Device"], selectedIndex: .constant(3))
    }
}

struct CustomSegmentView_One_Element_Previews: PreviewProvider {
    static var previews: some View {
        CustomSegmentView(options: ["Measurements"], selectedIndex: .constant(0))
    }
}

struct CustomSegmentView_Plain_Previews: PreviewProvider {
    static var previews: some View {
        CustomSegmentView(options: ["Measurements", "Forecast", "Rewards"],
                          selectedIndex: .constant(0),
                          style: .plain)
    }
}
