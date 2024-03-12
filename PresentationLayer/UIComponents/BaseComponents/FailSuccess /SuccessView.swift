//
//  SuccessView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 3/2/23.
//

import SwiftUI
import Toolkit

struct SuccessView: View {
    let title: String
    let subtitle: AttributedString?
    let buttonTitle: String
    let buttonAction: VoidCallback?

    @State private var bottomButtonsSize: CGSize = .zero
    private let iconDimensions: CGFloat = 150.0

    var body: some View {
        ZStack {
            if let buttonAction {
                VStack {
                    Spacer()
                    Button(action: buttonAction) {
                        Text(buttonTitle)
                    }
                    .buttonStyle(WXMButtonStyle.filled())
                    .sizeObserver(size: $bottomButtonsSize)
                }
            }

            VStack(spacing: CGFloat(.defaultSpacing)) {
                lottieViewLoading
                    .background {
                        Circle().foregroundColor(Color(colorEnum: .successTint))
                    }

                VStack(spacing: CGFloat(.smallSpacing)) {
                    Text(title)
                        .font(.system(size: CGFloat(.largeTitleFontSize), weight: .bold))
                        .foregroundColor(Color(colorEnum: .text))

                    if let subtitle {
                        Text(subtitle)
                            .font(.system(size: CGFloat(.mediumFontSize)))
                            .foregroundColor(Color(colorEnum: .text))
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(.bottom, bottomButtonsSize.height)
        }
    }
}

extension SuccessView {
    init(obj: FailSuccessStateObject) {
        self.title = obj.title
        self.subtitle = obj.subtitle
        self.buttonTitle = obj.retryTitle ?? ""
        self.buttonAction = obj.retryAction
    }
}

private extension SuccessView {
    @ViewBuilder
    var lottieViewLoading: some View {
        LottieView(animationCase: AnimationsEnums.success.animationString, loopMode: .playOnce)
            .frame(width: iconDimensions, height: iconDimensions)
    }
}

struct SuccessView_Previews: PreviewProvider {
    static var previews: some View {
        SuccessView(title: "Station Updated!",
                    subtitle: "Your station is updated to the latest Firmware!",
                    buttonTitle: "View Station") {}
            .padding()
    }
}
