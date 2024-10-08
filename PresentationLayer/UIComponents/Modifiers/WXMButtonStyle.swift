//
//  WXMButtonStyle.swift
//  PresentationLayer
//
//  Created by Manolis Katsifarakis on 1/10/22.
//

import SwiftUI

struct WXMButtonStyle: ButtonStyle {
    private let textColor: Color
    private let textColorDisabled: Color
    private let fillColor: Color
    private let fillColorDisabled: Color
    private let strokeColor: Color
    private let strokeColorDisabled: Color
	private let cornerRadius: CGFloat
    private let fixedSize: Bool

    @Environment(\.isEnabled) private var isEnabled: Bool

    init(
        textColor: ColorEnum = .wxmPrimary,
        textColorDisabled: ColorEnum = .darkGrey,
        fillColor: ColorEnum = .noColor,
        fillColorDisabled: ColorEnum = .midGrey,
        strokeColor: ColorEnum = .wxmPrimary,
        strokeColorDisabled: ColorEnum = .midGrey,
		cornerRadius: CGFloat = CGFloat(.buttonCornerRadius),
        fixedSize: Bool = false
    ) {
        self.fillColor = Color(colorEnum: fillColor)
        self.fillColorDisabled = Color(colorEnum: fillColorDisabled)
        self.textColor = Color(colorEnum: textColor)
        self.textColorDisabled = Color(colorEnum: textColorDisabled)
        self.strokeColor = Color(colorEnum: strokeColor)
        self.strokeColorDisabled = Color(colorEnum: strokeColorDisabled)
		self.cornerRadius = cornerRadius
        self.fixedSize = fixedSize
    }

    private init(textColor: Color,
                 textColorDisabled: Color,
                 fillColor: Color,
                 fillColorDisabled: Color,
                 strokeColor: Color,
                 strokeColorDisabled: Color,
				 cornerRadius: CGFloat = CGFloat(.buttonCornerRadius),
                 fixedSize: Bool = false) {
        self.fillColor = fillColor
        self.fillColorDisabled = fillColorDisabled
        self.textColor = textColor
        self.textColorDisabled = textColorDisabled
        self.strokeColor = strokeColor
        self.strokeColorDisabled = strokeColorDisabled
		self.cornerRadius = cornerRadius
        self.fixedSize = fixedSize
    }

    func makeBody(configuration: Self.Configuration) -> some View {
        let stroke = isEnabled ? strokeColor : strokeColorDisabled
        let fill = isEnabled ? fillColor : fillColorDisabled
        configuration.label
            .font(.system(size: CGFloat(.normalFontSize), weight: .bold))
            .foregroundColor(isEnabled ? textColor : textColorDisabled)
            .if(!fixedSize) { view in
                view.frame(maxWidth: .infinity)
                    .frame(height: 50)
            }
            .background {
                fill
            }
            .strokeBorder(color: stroke, lineWidth: 2.0, radius: cornerRadius)
            .opacity(configuration.isPressed ? 0.7 : 1)
            .contentShape(Rectangle())
            .cornerRadius(cornerRadius)
    }
}

extension WXMButtonStyle {
    static func filled(fixedSize: Bool = false) -> Self {
        Self.init(textColor: .top,
                  fillColor: .wxmPrimary,
                  fixedSize: fixedSize)
    }

    static func plain(fixedSize: Bool = false) -> Self {
        Self.init(strokeColor: .noColor,
                  fixedSize: fixedSize)
    }

    static var solid: Self {
        Self.init(textColor: Color(colorEnum: .wxmPrimary),
                  textColorDisabled: Color(colorEnum: .midGrey),
                  fillColor: Color(colorEnum: .top),
                  fillColorDisabled: Color(colorEnum: .midGrey).opacity(0.15),
                  strokeColor: Color(colorEnum: .wxmPrimary),
                  strokeColorDisabled: Color(colorEnum: .midGrey))
    }

	static var transparent: Self {
		Self.init(textColor: Color(colorEnum: .wxmPrimary),
				  textColorDisabled: Color(colorEnum: .midGrey),
				  fillColor: Color(colorEnum: .trasnparentButtonBg),
				  fillColorDisabled: Color(colorEnum: .midGrey).opacity(0.15),
				  strokeColor: Color.clear,
				  strokeColorDisabled: Color.clear)
	}

	static var transparentFixedSize: Self {
		Self.init(textColor: Color(colorEnum: .wxmPrimary),
				  textColorDisabled: Color(colorEnum: .midGrey),
				  fillColor: Color(colorEnum: .trasnparentButtonBg),
				  fillColorDisabled: Color(colorEnum: .midGrey).opacity(0.15),
				  strokeColor: Color.clear,
				  strokeColorDisabled: Color.clear,
				  fixedSize: true)
	}

	static func transparent(fillColor: ColorEnum) -> Self {
		Self.init(textColor: Color(colorEnum: .wxmPrimary),
				  textColorDisabled: Color(colorEnum: .midGrey),
				  fillColor: Color(colorEnum: fillColor).opacity(0.5),
				  fillColorDisabled: Color(colorEnum: .midGrey).opacity(0.15),
				  strokeColor: Color.clear,
				  strokeColorDisabled: Color.clear)
	}
}
