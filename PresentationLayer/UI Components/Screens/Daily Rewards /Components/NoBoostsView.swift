//
//  NoBoostsView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 1/3/24.
//

import SwiftUI

struct NoBoostsView: View {
    var body: some View {
		VStack(spacing: CGFloat(.minimumSpacing)) {
			HStack {
				Text(LocalizableString.RewardDetails.noActiveBoostsTitle.localized)
					.foregroundColor(Color(colorEnum: .text))
					.font(.system(size: CGFloat(.normalFontSize), weight: .medium))
				Spacer()
			}

			HStack {
				Text(LocalizableString.RewardDetails.noActiveBoostsDescription.localized)
					.foregroundColor(Color(colorEnum: .text))
					.font(.system(size: CGFloat(.normalFontSize)))
				Spacer()
			}
		}
		.WXMCardStyle()
    }
}

#Preview {
    NoBoostsView()
		.wxmShadow()
		.padding()
}
