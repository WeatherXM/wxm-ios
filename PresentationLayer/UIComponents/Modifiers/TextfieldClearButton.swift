//
//  TextfieldClearButton.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 21/6/23.
//

import SwiftUI

@MainActor
private struct TextfieldClearButtonModifier: ViewModifier {
    @Binding var text: String
    @Binding var isLoading: Bool
    let icon: AssetEnum

    @State private var clearIconSize: CGSize = .zero

    func body(content: Content) -> some View {
        HStack {
            content
                .padding(.trailing, text.isEmpty ? 0.0 : clearIconSize.width)
                .overlay {
                    HStack {
                        Spacer()

                        if !text.isEmpty {
                            ZStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(.circular)
                                        .tint(Color(colorEnum: .text))
                                        .frame(width: clearIconSize.width)
                                } else {
                                    Button {
                                        text.removeAll()
                                    } label: {
                                        Image(asset: icon)
                                            .renderingMode(.template)
                                            .foregroundColor(Color(colorEnum: .text))
                                    }
                                    .transition(AnyTransition.opacity.animation(.easeIn(duration: 0.1)))
                                    .sizeObserver(size: $clearIconSize)
                                }
                            }
                            .multilineTextAlignment(.center)
                        }
                    }
                }

        }
    }
}

@MainActor
extension TextField {
    @ViewBuilder
    func textFieldClearButton(text: Binding<String>,
                              isLoading: Binding<Bool>,
                              icon: AssetEnum) -> some View {
        modifier(TextfieldClearButtonModifier(text: text, isLoading: isLoading, icon: icon))
    }
}

struct Previews_TextfieldClearButton_Previews: PreviewProvider {
    static var previews: some View {
        TextField("Search here", text: .constant(""))
            .textFieldClearButton(text: .constant("fewf"), isLoading: .constant(true), icon: .clearIcon)

    }
}
