//
//  WXMEmptyView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 13/6/23.
//

import SwiftUI
import Toolkit

struct WXMEmptyView: View {
    let configuration: Configuration
    let iconDimensions: CGFloat = 150

    var body: some View {
        ZStack {
			Color(colorEnum: configuration.backgroundColor)
                .ignoresSafeArea()

            VStack(spacing: CGFloat(.mediumSpacing)) {
				#if MAIN_APP
                if let animationEnum = configuration.animationEnum {
                    LottieView(animationCase: animationEnum.animationString, loopMode: .playOnce)
                        .frame(width: iconDimensions, height: iconDimensions)
				} else if let image = configuration.image {
					Image(asset: image.icon)
						.if(image.tintColor != nil) { view in
							view.renderingMode(.template).foregroundColor(Color(colorEnum: image.tintColor!))
						}
				} else if let imageFontIcon = configuration.imageFontIcon {
					Text(imageFontIcon.icon.rawValue)
						.font(.fontAwesome(font: imageFontIcon.font,
										   size: CGFloat(.maxFontSize)))
						.foregroundStyle(Color(colorEnum: .darkGrey))
				}

				#else
				if let image = configuration.image {
					Image(asset: image.icon)
						.if(image.tintColor != nil) { view in
							view.renderingMode(.template).foregroundColor(Color(colorEnum: image.tintColor!))
						}
				}
				#endif

                VStack(spacing: CGFloat(.defaultSpacing)) {
                    VStack(spacing: CGFloat(.smallSpacing)) {
                        if let title = configuration.title {
                            Text(title)
                                .font(.system(size: CGFloat(.smallTitleFontSize), weight: .bold))
                                .foregroundColor(Color(colorEnum: .text))
                                .multilineTextAlignment(.center)
								.minimumScaleFactor(0.7)
                        }

                        if let description = configuration.description {
                            Text(description)
                                .font(.system(size: CGFloat(.normalFontSize)))
                                .foregroundColor(Color(colorEnum: .text))
                                .multilineTextAlignment(.center)
								.minimumScaleFactor(0.7)
                        }
                    }

                    if let action = configuration.action,
                       let buttonTitle = configuration.buttonTitle {
                        Button(action: action) {
							HStack(spacing: CGFloat(.smallToMediumSpacing)) {
                                if let fontIcon = configuration.buttonFontIcon {
									Text(fontIcon.icon.rawValue)
										.font(.fontAwesome(font: fontIcon.font,
														   size: CGFloat(.mediumFontSize)))
                                }
                                Text(buttonTitle)
                            }
                        }
                        .buttonStyle(WXMButtonStyle.filled())
                    }
                }
            }
			.if(configuration.enableSidePadding) { view in
				view
					.padding(CGFloat(.XLSidePadding))
			}
        }
    }
}

extension WXMEmptyView {
    struct Configuration {
		var image: (icon: AssetEnum, tintColor: ColorEnum?)?
		#if MAIN_APP
        var animationEnum: AnimationsEnums?
		#endif
		var backgroundColor: ColorEnum = .bg
		var imageFontIcon: (icon: FontIcon, font: FontAwesome)?
		var enableSidePadding: Bool = true
        let title: String?
        let description: AttributedString?
		var buttonFontIcon: (icon: FontIcon, font: FontAwesome)?
        var buttonTitle: String?
        var action: VoidCallback?
    }
}

struct WXMEmptyView_Previews: PreviewProvider {
    static var previews: some View {
        let conf = WXMEmptyView.Configuration(image: (.lockedIcon, .wxmPrimary),
                                              title: "SERVICE UNAVAILABLE",
                                              description: "Server busy, site may have moved or you lost your dial-up Internet connection",
											  buttonFontIcon: (.gear, .FAPro),
                                              buttonTitle: "Reload") { }
        WXMEmptyView(configuration: conf)
    }
}

private struct WXMEmptyViewModifier: ViewModifier {
    @Binding var show: Bool
    let conf: WXMEmptyView.Configuration

    func body(content: Content) -> some View {
        content
            .if(show) { view in
                view.hidden()
            }
            .overlay {
                if show {
                    WXMEmptyView(configuration: conf)
						.modify { view in
							#if MAIN_APP
							view.iPadMaxWidth()
							#else
							view
							#endif
						}
                        .padding()
                }
            }
    }
}

extension View {
    @ViewBuilder
    func wxmEmptyView(show: Binding<Bool>, configuration: WXMEmptyView.Configuration?) -> some View {
        if let configuration {
            modifier(WXMEmptyViewModifier(show: show,
                                          conf: configuration))
        } else {
            self
        }
    }
}
