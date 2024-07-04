//
//  CustomPicker.swift
//  PresentationLayer
//
//  Created by Manolis Katsifarakis on 7/12/22.
//

import SwiftUI

struct CustomPicker<Item: Equatable & Hashable>: View {
    let items: [Item]
    @Binding var selectedItem: Item?
    let textCallback: (Item?) -> String

    @State private var isOpen: Bool = false

    private let PICKER_HEIGHT: CGFloat = 50
    private let ROW_HEIGHT: CGFloat = 50

    var body: some View {
        content
    }

    var content: some View {
        return pickerField
            .onChange(of: isOpen) { isOpen in
                guard isOpen else {
                    CustomPickerManager.default.customPickerHostController?.view.removeFromSuperview()
                    CustomPickerManager.default.customPickerHostController = nil
                    return
                }

                if let rootView = UIApplication.shared.topViewController?.view {
                    CustomPickerManager.default.containerBounds = rootView.bounds
                    let host = UIHostingController(rootView: AnyView(pickerListWithOverlay))
                    CustomPickerManager.default.customPickerHostController = host
                    host.view.backgroundColor = UIColor.clear
                    host.view.frame = rootView.bounds
                    rootView.addSubview(host.view)
                }
            }
    }

    @ViewBuilder
    var pickerField: some View {
        let item = selectedItem ?? items.first
        GeometryReader { geometry in
            Button {
                self.isOpen.toggle()
            } label: {
                HStack {
                    Text(textCallback(item))
                        .font(.system(size: CGFloat(.normalFontSize)))
                        .foregroundColor(Color(colorEnum: .text))

                    Spacer()

                    Image(asset: .chevronDown)
                        .renderingMode(.template)
                        .foregroundColor(Color(colorEnum: .text))
                        .frame(width: 30)
                }
                .frame(width: geometry.size.width - 32)
                .padding()
            }
            .buttonStyle(CustomColorButtonStyle())
            .frame(height: PICKER_HEIGHT)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color(colorEnum: .midGrey), lineWidth: 1)
            )
            .anchorPreference(key: ViewAnchorKey.self, value: .bounds) {
                CustomPickerManager.default.pickerFieldFrame = geometry.frame(in: .global)
                return ViewAnchorData(bounds: geometry[$0])
            }
        }
        .frame(height: PICKER_HEIGHT)
        .padding(.horizontal, 1)
        .onPreferenceChange(ViewAnchorKey.self) { _ in }
    }

    var pickerListWithOverlay: some View {
        ZStack(alignment: .topLeading) {
            let offsetX = CustomPickerManager.default.pickerFieldFrame.origin.x
            let offsetY = CustomPickerManager.default.pickerFieldFrame.origin.y + PICKER_HEIGHT
            let width = CustomPickerManager.default.pickerFieldFrame.size.width

            let totalHeight = CustomPickerManager.default.containerBounds.size.height
            let maxHeight = max(0, totalHeight - offsetY - totalHeight * 0.1)
            let height = min(CGFloat(items.count) * ROW_HEIGHT, maxHeight)

            Color.black.opacity(0.01)
            pickerList
                .offset(
                    x: offsetX,
                    y: offsetY
                )
                .frame(
                    maxWidth: width,
                    maxHeight: height,
                    alignment: .topLeading
                )
        }
        .onTapGesture {
            isOpen = false
        }
        .edgesIgnoringSafeArea(.all)
    }

    @ViewBuilder
    var pickerList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(items, id: \.self) { item in
                    row(item)
                }
            }
        }
        .background(Color(colorEnum: .top))
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(Color(.lightGray), lineWidth: 1)
        )
    }
}

private extension CustomPicker {
    func row(_ item: Item) -> some View {
        let row = Button {
            selectedItem = item
            isOpen = false
        } label: {
            VStack {
                Spacer()

                HStack {
                    Text(textCallback(item))
                        .font(.system(size: CGFloat(.normalFontSize)))
                        .foregroundColor(Color(colorEnum: .text))

                    Spacer()
                }
                .padding(.horizontal, 16)

                Spacer()

                WXMDivider()
            }
        }
        .buttonStyle(
            CustomColorButtonStyle(
                backgroundColor: selectedItem == item ? Color(colorEnum: .blueTint) : Color(colorEnum: .top)
            )
        )
        .frame(height: ROW_HEIGHT)

        return row
    }

    struct ViewAnchorKey: PreferenceKey {
        static var defaultValue: CustomPicker.ViewAnchorData {
            return ViewAnchorData(bounds: CGRect.zero)
        }

        static func reduce(value: inout ViewAnchorData, nextValue: () -> ViewAnchorData) {
            value.bounds = nextValue().bounds
        }
    }

    struct ViewAnchorData: Equatable {
        var bounds: CGRect
        static func == (_: ViewAnchorData, _: ViewAnchorData) -> Bool {
            return false
        }
    }
}

private class CustomPickerManager {
    private init() {}

    var customPickerHostController: UIHostingController<AnyView>?

    static let `default` = CustomPickerManager()

    var pickerFieldFrame: CGRect = .zero
    var containerBounds: CGRect = .zero
    var contentHeight: CGFloat = 0
}
