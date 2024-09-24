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
		switch obj.failMode {
			case .default:
				defaultView
			case .retry:
				retryView
		}
	}

    var defaultView: some View {
        ZStack {
			if obj.actionButtonsAtTheBottom {
				VStack {
					Spacer()

					actionButtons
						.sizeObserver(size: $bottomButtonsSize)
				}
            }

			GeometryReader { proxy in
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
					// Set min height in order to keep the content centered
					.frame(minHeight: proxy.size.height)
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

	@ViewBuilder
	var retryView: some View {
		Button { 
			obj.retryAction?()
		} label: {
			VStack(spacing: CGFloat(.mediumSpacing)) {
				Text(FontIcon.rotateRight.rawValue)
					.font(.fontAwesome(font: .FAProSolid, size: CGFloat(.XXLTitleFontSize)))
					.foregroundStyle(Color(colorEnum: .text))

				VStack(spacing: 0.0) {
					Text(obj.title)
						.font(.system(size: CGFloat(.largeFontSize), weight: .bold))
						.foregroundColor(Color(colorEnum: .text))
						.multilineTextAlignment(.center)

					if let subtitle = obj.subtitle {
						Text(subtitle)
							.font(.system(size: CGFloat(.mediumFontSize)))
							.foregroundColor(Color(colorEnum: .text))
							.multilineTextAlignment(.center)
					}
				}
			}
		}
	}
}

extension FailView {
	enum Mode {
		case `default`
		case retry
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
		VStack(spacing: CGFloat(.mediumSpacing)) {

			if let info = obj.info {
				InfoView(text: info)
					.onAppear {
						obj.infoOnAppearAction?()
					}
			}

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
