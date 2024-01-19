//
//  ProgressBar.swift
//  PresentationLayer
//
//  Created by Danae Kikue Dimou on 12/9/22.
//

import SwiftUI

struct ProgressBar: View {
    let colorOfProgressBar: Color
    let progressOfBar: Double

    var body: some View {
        progressBar
            .frame(height: 16)
    }

    var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                backgroundPartOfBar
                    .frame(width: geometry.size.width)
                activePartOfBar
                    .frame(width: geometry.size.width * progressOfBar)
            }
        }
    }

    var backgroundPartOfBar: some View {
        Rectangle()
            .fill(Color(colorEnum: .layer2))
            .cornerRadius(CGFloat(.buttonCornerRadius))
    }

    var activePartOfBar: some View {
        Rectangle()
            .fill(colorOfProgressBar)

            .cornerRadius(CGFloat(.buttonCornerRadius))
    }
}
