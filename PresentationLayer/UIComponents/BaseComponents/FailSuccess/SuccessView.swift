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
	var info: CardWarningConfiguration?
	var infoCustomView: AnyView? = nil
	var infoOnAppearAction: VoidCallback?
	let actionButtonsLayout: FailSuccessStateObject.ActionButtonsLayout
    let buttonTitle: String
    let buttonAction: VoidCallback?
	var secondaryButtonTitle: String?
	var secondaryButtonAction: VoidCallback?

    @State private var bottomButtonsSize: CGSize = .zero
    private let iconDimensions: CGFloat = 150.0

    var body: some View {
		ZStack {
			VStack {
				Spacer()

				VStack(spacing: CGFloat(.mediumSpacing)) {
					if let info {
						CardWarningView(configuration: info) {
							Group {
								if let infoCustomView {
									infoCustomView
								} else {
									EmptyView()
								}
							}
						}
						.onAppear {
							infoOnAppearAction?()
						}
					}

					actionButtons
				}
				.sizeObserver(size: $bottomButtonsSize)
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
		self.info = obj.info
		self.infoCustomView = obj.infoCustomView
		self.infoOnAppearAction = obj.infoOnAppearAction
		self.actionButtonsLayout = obj.actionButtonsLayout
        self.buttonTitle = obj.retryTitle ?? ""
        self.buttonAction = obj.retryAction
		self.secondaryButtonTitle = obj.cancelTitle
		self.secondaryButtonAction = obj.cancelAction
    }
}

private extension SuccessView {
    @ViewBuilder
    var lottieViewLoading: some View {
        LottieView(animationCase: AnimationsEnums.success.animationString, loopMode: .playOnce)
            .frame(width: iconDimensions, height: iconDimensions)
    }

	@ViewBuilder
	var actionButtons: some View {
		let layout = actionButtonsLayout == .horizontal ?
		AnyLayout(HStackLayout(spacing: CGFloat(.defaultSpacing))) : AnyLayout(VStackLayout(spacing: CGFloat(.smallToMediumSpacing)))

		layout {
			orderedActionButtons
		}
	}

	@ViewBuilder
	var orderedActionButtons: some View {
		switch actionButtonsLayout {
			case .horizontal:
				secondaryButton
				primaryButton
			case .vertical:
				primaryButton
				secondaryButton
		}
	}

	@ViewBuilder
	var secondaryButton: some View {
		if let secondaryButtonTitle, let secondaryButtonAction {
			Button(action: secondaryButtonAction) {
				Text(secondaryButtonTitle)
			}
			.buttonStyle(WXMButtonStyle())
		}
	}

	@ViewBuilder
	var primaryButton: some View {
		if let buttonAction {
			Button(action: buttonAction) {
				Text(buttonTitle)
			}
			.buttonStyle(WXMButtonStyle.filled())
		}
	}
}

struct SuccessView_Previews: PreviewProvider {
    static var previews: some View {
		SuccessView(title: "Station Updated!",
					subtitle: "Your station is updated to the latest Firmware!",
					info: .init(type: .info, message: "Info text", closeAction: nil),
					actionButtonsLayout: .horizontal,
					buttonTitle: "View Station",
					buttonAction: {},
					secondaryButtonTitle: "Cancel",
					secondaryButtonAction: { })
		.padding()
    }
}
