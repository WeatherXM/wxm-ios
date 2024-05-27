//
//  ClaimStationSelectionView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 29/4/24.
//

import SwiftUI

struct ClaimStationSelectionView: View {
	@StateObject var viewModel: ClaimStationSelectionViewModel
	@EnvironmentObject var navigationObject: NavigationObject

    var body: some View {
		ZStack {
			Color(colorEnum: .newBG)
				.ignoresSafeArea()

			ScrollView(showsIndicators: false) {
				VStack(spacing: CGFloat(.mediumSpacing)) {
					HStack {
						Text(LocalizableString.ClaimDevice.selectType.localized)
							.foregroundStyle(Color(colorEnum: .darkestBlue))
							.font(.system(size: CGFloat(.smallTitleFontSize), weight: .bold))
						Spacer()
					}

					selectionGrid
				}
				.padding(.horizontal, CGFloat(.mediumSidePadding))
				.padding(.vertical, CGFloat(.mediumToLargeSidePadding))
				.iPadMaxWidth()
			}
		}
		.onAppear {
			navigationObject.title = LocalizableString.ClaimDevice.selectionNavigationTitle.localized
		}
    }
}

private extension ClaimStationSelectionView {
	@ViewBuilder
	var selectionGrid: some View {
		LazyVGrid(columns: [.init(spacing: CGFloat(.mediumSpacing)), .init()],
				  spacing: CGFloat(.mediumSpacing)) {
			Group {
				ForEach(ClaimStationType.allCases, id: \.self) { type in
					Button {
						viewModel.handleTypeTap(type)
					} label: {
						VStack(spacing: CGFloat(.smallSpacing)) {
							Image(asset: type.image)
								.resizable()
								.aspectRatio(contentMode: .fill)
							Text(type.description)
								.foregroundStyle(Color(colorEnum: .darkestBlue))
								.font(.system(size: CGFloat(.mediumFontSize), weight: .bold))
						}
						.WXMCardStyle()
					}
					.wxmShadow()
				}
			}
		}
	}
}

#Preview {
	NavigationContainerView {
		ClaimStationSelectionView(viewModel: .init())
	}
}
