//
//  CTAView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 3/8/23.
//

import SwiftUI
import Toolkit

struct CTAContainerView: View {
    let ctaObject: CTAObject

    var body: some View {
		HStack(spacing: CGFloat(.smallSpacing)) {
            HStack {
                Text(ctaObject.description)
                    .font(.system(size: CGFloat(.caption)))
                    .foregroundColor(Color(colorEnum: .text))

                Spacer(minLength: 0.0)
            }

            Button {
                ctaObject.buttonAction()
            } label: {
				HStack(spacing: CGFloat(.smallToMediumSpacing)) {
                    Text(ctaObject.buttonFontIcon.rawValue)
						.font(.fontAwesome(font: .FAPro, size: CGFloat(.mediumFontSize)))
                    Text(ctaObject.buttonTitle)
                }
                .padding(.horizontal, CGFloat(.defaultSidePadding))
            }
            .buttonStyle(WXMButtonStyle.filled())
            .fixedSize()
        }
		.padding(.trailing, CGFloat(.smallSidePadding))
        .padding(.leading, CGFloat(.mediumSidePadding))
        .padding(.vertical, CGFloat(.smallSidePadding))
        .WXMCardStyle(backgroundColor: Color(colorEnum: .top),
                      insideHorizontalPadding: 0.0,
                      insideVerticalPadding: 0.0)
    }
}

extension CTAContainerView {
    struct CTAObject {
        let description: String
        let buttonTitle: String
        let buttonFontIcon: FontIcon
        let buttonAction: VoidCallback
    }
}

struct CTAContainerView_Previews: PreviewProvider {
    static var previews: some View {
        CTAContainerView(ctaObject: .init(description: "Add weather station to your favourites to see historical & forecast data.",
                                          buttonTitle: "Follow",
                                          buttonFontIcon: .heart) {})
    }
}
