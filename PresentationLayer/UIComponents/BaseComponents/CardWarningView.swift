//
//  CardWarningView.swift
//  PresentationLayer
//
//  Created by Pantelis Giazitsis on 31/1/23.
//

import SwiftUI

/// A card to show warning. Requires `title` `message`. If passed a `closeAction` will render an `x` button on the top right side.
/// `content` used to provide a custom view which will be rendered below the`message` text. If `showContentFullWidth` is true the `content` will cover the view edge to edge
struct CardWarningView<Content: View>: View {
    var type: CardWarningType = .warning
    var showIcon = true
    var title: String?
    let message: String
    var showContentFullWidth: Bool = false
	var showBorder: Bool = false
    let closeAction: (() -> Void)?
    var content: () -> Content

    var body: some View {
        VStack(spacing: CGFloat(.smallSpacing)) {
            HStack(spacing: CGFloat(.smallSpacing)) {
                if showIcon {
                    Image(asset: type.icon)
                        .renderingMode(.template)
                        .foregroundColor(Color(colorEnum: type.iconColor))
                }

                VStack(alignment: .leading, spacing: CGFloat(.minimumSpacing)) {
                    HStack {
                        if let title {
                            Text(title)
                                .foregroundColor(Color(colorEnum: .text))
                                .font(.system(size: CGFloat(.mediumFontSize), weight: .bold))
                        }

                        Spacer()

                        if let closeAction {
                            Button(action: closeAction) {
                                Image(asset: .toggleXMark)
                                    .renderingMode(.template)
                                    .foregroundColor(Color(colorEnum: .text))
                            }
                        }
                    }

                    Text(message.attributedMarkdown ?? "")
                        .foregroundColor(Color(colorEnum: .text))
                        .font(.system(size: CGFloat(.normalFontSize)))
                        .fixedSize(horizontal: false, vertical: true)

                    if !showContentFullWidth {
                        content()
                    }
                }
            }

            if showContentFullWidth {
                content()
            }
        }
        .WXMCardStyle(backgroundColor: Color(colorEnum: type.tintColor),
                            cornerRadius: CGFloat(.buttonCornerRadius))
		.if(showBorder) { view in
			view.strokeBorder(color: Color(colorEnum: type.iconColor), lineWidth: 1.0, radius: CGFloat(.buttonCornerRadius))
		}
    }
}

enum CardWarningType {
    case warning
    case error
	case info

	var icon: AssetEnum {
		switch self {
			case .warning:
				return .warningIcon
			case .error:
				return .errorIcon
			case .info:
				return .infoIcon
		}
	}

	var iconColor: ColorEnum {
		switch self {
			case .warning:
				return .warning
			case .error:
				return .error
			case .info:
				return .info
		}
	}

	var tintColor: ColorEnum {
		switch self {
			case .warning:
				return .warningTint
			case .error:
				return .errorTint
			case .info:
				return .infoTint
		}
	}
}

struct Previews_CardWarningView_Previews: PreviewProvider {
    static var previews: some View {
		CardWarningView(type: .info,
						title: "This is title",
						message: "This is a warning text", closeAction: nil) {
            EmptyView()
        }
    }
}
