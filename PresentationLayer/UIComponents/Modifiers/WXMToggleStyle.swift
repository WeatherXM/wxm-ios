//
//  ColoredToggleStyle.swift
//  PresentationLayer
//
//  Created by Manolis Katsifarakis on 15/10/22.
//

import SwiftUI

struct WXMToggleStyle: ToggleStyle {
    static var Default: WXMToggleStyle = .init(
        onColor: Color(colorEnum: .wxmPrimary),
        onIcon: Image(asset: .toggleCheckmark),
        offIcon: Image(asset: .toggleXMark),
        thumbColorOff: Color(colorEnum: .darkGrey),
        strokeColorOff: Color(colorEnum: .darkGrey)
    )

    var label = ""
    var onColor = Color(UIColor.green)
    var offColor = Color(UIColor.systemGray5)
    var onIcon: Image?
    var offIcon: Image?
    var thumbPadding: CGFloat = 2
    var thumbColorOn = Color.white
    var thumbColorOff = Color.white
    var strokeColorOn = Color.clear
    var strokeColorOff = Color.clear
    var strokeWidth: CGFloat = 1

    func makeBody(configuration: Self.Configuration) -> some View {
        HStack {
            let overlayIcon = configuration.isOn && onIcon != nil || !configuration.isOn && offIcon != nil
                ? configuration.isOn ? onIcon! : offIcon!
                : nil

            let circle = Circle()
                .fill(configuration.isOn ? thumbColorOn : thumbColorOff)
                .overlay(overlayIcon)
                .shadow(radius: 1, x: 0, y: 1)
                .padding(thumbPadding)
                .offset(x: configuration.isOn ? 10 : -10)

            if !label.isEmpty {
                Text(label)
                Spacer()
            }

			Button {
				configuration.isOn.toggle()
			} label: {
                RoundedRectangle(cornerRadius: 16, style: .circular)
                    .style(
                        withStroke: configuration.isOn ? strokeColorOn : strokeColorOff,
                        lineWidth: strokeWidth,
                        fill: configuration.isOn ? onColor : offColor
                    )
                    .frame(width: 50, height: 29)
                    .overlay(circle)
                    .animation(Animation.easeInOut(duration: 0.1), value: configuration.isOn)
            }
            .buttonStyle(StaticButtonStyle())
        }
        .font(.title)
    }
}
