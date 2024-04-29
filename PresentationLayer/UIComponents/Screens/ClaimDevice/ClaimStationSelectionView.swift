//
//  ClaimStationSelectionView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 29/4/24.
//

import SwiftUI

struct ClaimStationSelectionView: View {
	@EnvironmentObject var navigationObject: NavigationObject

    var body: some View {
		ScrollView(showsIndicators: false) {
			VStack(spacing: CGFloat(.mediumSpacing)) {
				HStack {
					Text(LocalizableString.ClaimDevice.selectType.localized)
						.foregroundStyle(Color(colorEnum: .darkestBlue))
						.font(.system(size: CGFloat(.smallTitleFontSize), weight: .bold))
					Spacer()
				}
			}
			.padding(.horizontal, CGFloat(.mediumSidePadding))
			.padding(.vertical, CGFloat(.mediumToLargeSidePadding))
		}
		.onAppear {
			navigationObject.title = LocalizableString.ClaimDevice.selectionNavigationTitle.localized
		}
    }
}

#Preview {
	NavigationContainerView {
		ClaimStationSelectionView()
	}
}
