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
		onColorDisabled: Color(colorEnum: .midGrey),
		offColorDisabled: Color(colorEnum: .layer2),
        onIcon: Image(asset: .toggleCheckmark),
        offIcon: Image(asset: .toggleXMark),
        thumbColorOff: Color(colorEnum: .darkGrey),
		thumbColorOffDisabled: Color(colorEnum: .midGrey),
        strokeColorOff: Color(colorEnum: .darkGrey),
		strokeColorOffDisabled: Color(colorEnum: .midGrey)
    )

    var label = ""
    var onColor = Color(UIColor.green)
	var onColorDisabled = Color(UIColor.green)
    var offColor = Color(UIColor.systemGray5)
	var offColorDisabled = Color(UIColor.systemGray5)
    var onIcon: Image?
    var offIcon: Image?
    var thumbPadding: CGFloat = 2
    var thumbColorOn = Color.white
    var thumbColorOff = Color.white
	var thumbColorOffDisabled = Color.white
    var strokeColorOn = Color.clear
    var strokeColorOff = Color.clear
	var strokeColorOffDisabled = Color.clear
    var strokeWidth: CGFloat = 1

	@Environment(\.isEnabled) var isEnabled

    func makeBody(configuration: Self.Configuration) -> some View {
        HStack {			
            let overlayIcon = configuration.isOn && onIcon != nil || !configuration.isOn && offIcon != nil
                ? configuration.isOn ? onIcon! : offIcon!
                : nil

            let circle = Circle()
				.fill(thumbColor(configuration: configuration))
                .overlay(overlayIcon)
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
						withStroke: strokeColor(configuration: configuration),
                        lineWidth: strokeWidth,
						fill: fillColor(configuration: configuration)
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

private extension WXMToggleStyle {
	func fillColor(configuration: Configuration) -> Color {
		var color = configuration.isOn ? onColor : offColor
		let disabledColor = configuration.isOn ? onColorDisabled : offColorDisabled
		color = isEnabled ? color : disabledColor
		return color
	}

	func strokeColor(configuration: Configuration) -> Color {
		var color = configuration.isOn ? strokeColorOn : strokeColorOff
		let disabledColor = strokeColorOffDisabled
		color = isEnabled ? color : disabledColor
		return color
	}

	func thumbColor(configuration: Configuration) -> Color {
		let disabledColor = configuration.isOn ? thumbColorOn : thumbColorOffDisabled
		var color = configuration.isOn ? thumbColorOn : thumbColorOff
		color = isEnabled ? color : disabledColor
		return color
	}
}


#Preview {
	Toggle("", isOn: .constant(false))
		.labelsHidden()
		.toggleStyle(WXMToggleStyle.Default)
		.disabled(true)
}
