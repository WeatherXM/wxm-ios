//
//  ToastView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 14/3/23.
//

import SwiftUI
import Toolkit

struct ToastView: View {
    let text: AttributedString
    var type: ToastType = .error
    var dismissInterval = 3.0
    var dismissCompletion: VoidCallback?
    let retryAction: VoidCallback?

    @State private var offset: CGFloat = 150.0
    @State private var dismissItem: DispatchWorkItem?
    private let animationDuration = 0.2

    var body: some View {
		HStack(spacing: CGFloat(.smallSpacing)) {
            Text(text)
                .foregroundColor(Color(colorEnum: type.textColor))
                .font(.system(size: CGFloat(.normalFontSize)))
                .fixedSize(horizontal: false, vertical: true)

            Spacer()

            if let retryAction {
                Button {
                    dismissItem?.cancel()
                    dismiss {
                        retryAction()
                    }
                } label: {
                    Text(LocalizableString.retry.localized)
                        .foregroundColor(Color(colorEnum: type.textColor))
                        .font(.system(size: CGFloat(.normalFontSize), weight: .bold))
                }
            }
        }
        .WXMCardStyle(backgroundColor: Color(colorEnum: type.color),
                      insideHorizontalPadding: CGFloat(.mediumSidePadding))
        .wxmShadow()
        .padding()
        .offset(x: 0.0, y: offset)
        .onAppear {

            withAnimation(.easeOut(duration: animationDuration)) {
                offset = 0.0
            }

            let workItem = DispatchWorkItem {
                dismiss()
            }
            dismissItem = workItem
            DispatchQueue.main.asyncAfter(deadline: .now() + dismissInterval,
                                          execute: workItem)
        }

    }
}

private extension ToastView {
    func dismiss(completion: VoidCallback? = nil) {
        withAnimation(.easeIn(duration: animationDuration)) {
            offset = 150.0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
            dismissCompletion?()
            completion?()
        }
    }
}

extension ToastView {
    enum ToastType {
        case error
        case info

        var textColor: ColorEnum {
            switch self {
                case .error:
                    return .toastErrorText
                case .info:
                    return .text
            }
        }

        var color: ColorEnum {
            switch self {
                case .error:
                    return .toastErrorBg
                case .info:
                    return .toastInfoBg
            }
        }
    }
}

struct ToastView_Previews: PreviewProvider {
    static var previews: some View {
        ToastView(text: "Toast text here") {}
    }
}

struct ToastInfoView_Previews: PreviewProvider {
    static var previews: some View {
        ToastView(text: "Toast text here", type: .info) {}
    }
}
