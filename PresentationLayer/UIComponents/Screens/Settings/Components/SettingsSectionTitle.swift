//
//  SettingsSectionTitle.swift
//  PresentationLayer
//
//  Created by danaekikue on 17/6/22.
//

import SwiftUI

struct SettingsSectionTitle: View {
    let title: SettingsEnum

    var body: some View {
        Text(title.sectionTitle)
            .foregroundColor(Color(colorEnum: .primary))
            .font(.system(size: CGFloat(.mediumFontSize)))
    }
}
