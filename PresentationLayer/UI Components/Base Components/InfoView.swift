//
//  InfoView.swift
//  PresentationLayer
//
//  Created by Pantelis Giazitsis on 16/2/23.
//

import SwiftUI

struct InfoView: View {
    let text: AttributedString

    var body: some View {
        HStack(spacing: CGFloat(.smallSpacing)) {
            Image(asset: .infoIcon)
                .renderingMode(.template)
                .foregroundColor(Color(colorEnum: .darkestBlue))

            Text(text)
                .foregroundColor(Color(colorEnum: .text))
                .font(.system(size: CGFloat(.normalFontSize)))
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
        }
        .WXMCardStyle(backgroundColor: Color(colorEnum: .blueTint),
                      insideHorizontalPadding: CGFloat(.mediumSidePadding))
        .strokeBorder(color: Color(colorEnum: .darkestBlue),
                      lineWidth: 1.0,
                      radius: CGFloat(.cardCornerRadius))
    }
}

struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView(text: "There is a brand new firmware update for your station. **We highly recommend you update, as this will improve the experience you’ll have with your WeatherXM station!**".attributedMarkdown ?? "")
    }
}
