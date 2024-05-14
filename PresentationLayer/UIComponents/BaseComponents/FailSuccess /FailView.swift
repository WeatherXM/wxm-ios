//
//  FailView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 3/2/23.
//

import SwiftUI
import Toolkit

struct FailView: View {
    let obj: FailSuccessStateObject

    @State private var bottomButtonsSize: CGSize = .zero
    private let iconDimensions: CGFloat = 150

    var body: some View {
        ZStack {
			if obj.actionButtonsAtTheBottom {
				VStack {
					Spacer()

					actionButtons
						.sizeObserver(size: $bottomButtonsSize)
				}
            }

            ScrollView(showsIndicators: false) {
                VStack(spacing: CGFloat(.defaultSpacing)) {
                    Spacer()
                    lottieViewLoading
                        .background {
                            Circle().foregroundColor(Color(colorEnum: .errorTint))
                        }

                    VStack(spacing: CGFloat(.smallSpacing)) {
                        Text(obj.title)
                            .font(.system(size: CGFloat(.largeTitleFontSize), weight: .bold))
                            .foregroundColor(Color(colorEnum: .text))
                            .multilineTextAlignment(.center)

                        if let subtitle = obj.subtitle {
                            Text(subtitle)
                                .font(.system(size: CGFloat(.mediumFontSize)))
                                .foregroundColor(Color(colorEnum: .text))
                                .multilineTextAlignment(.center)
                        }
                    }

                    contactSupportButton

					if !obj.actionButtonsAtTheBottom {
						actionButtons
					}

                    Spacer()
                }
            }
            .padding(.bottom, bottomButtonsSize.height)
            .environment(\.openURL, OpenURLAction { url in
                if url.absoluteString == LocalizableString.ClaimDevice.failedTextLinkURL.localized {
                    return .handled
                }
                return .systemAction
            })
        }
        .onAppear {
            WXMAnalytics.shared.trackEvent(.viewContent, parameters: [.contentName: .failure,
                                                                .contentId: .failureContentId,
                                                                .itemId: .custom(obj.type.description)])
        }
    }
}

private extension FailView {
    @ViewBuilder
    var lottieViewLoading: some View {
        LottieView(animationCase: AnimationsEnums.fail.animationString, loopMode: .playOnce)
            .frame(width: iconDimensions, height: iconDimensions)
    }

    var contactSupportButton: some View {
        Button {
            obj.contactSupportAction?()
        } label: {
            Text(LocalizableString.contactSupport.localized)
        }
        .buttonStyle(WXMButtonStyle())
    }

	var actionButtons: some View {
		HStack(spacing: CGFloat(.mediumSpacing)) {
			if let cancelAction = obj.cancelAction {
				Button(action: cancelAction) {
					Text(obj.cancelTitle ?? "")
				}
				.buttonStyle(WXMButtonStyle())
			}

			if let retryAction = obj.retryAction {
				Button(action: retryAction) {
					Text(obj.retryTitle ?? "")
				}
				.buttonStyle(WXMButtonStyle.filled())
			}
		}
		.sizeObserver(size: $bottomButtonsSize)
	}
}

struct FailView_Previews: PreviewProvider {
    static var previews: some View {
        FailView(obj: FailSuccessStateObject.mockErrorObj)
            .padding()
    }
}
