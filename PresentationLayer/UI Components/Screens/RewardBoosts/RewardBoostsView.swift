//
//  RewardBoostsView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 6/3/24.
//

import SwiftUI

struct RewardBoostsView: View {
	@StateObject var viewModel: RewardBoostsViewModel

    var body: some View {
		TrackableScrollView {
			VStack(spacing: CGFloat(.mediumSpacing)) {
				BoostCardView(boost: viewModel.boost)
			}
			.padding(CGFloat(.mediumSidePadding))
		}
    }
}

#Preview {
	RewardBoostsView(viewModel: ViewModelsFactory.getRewardsBoostViewModel(boost: .mock,
																		   date: .now))
}
