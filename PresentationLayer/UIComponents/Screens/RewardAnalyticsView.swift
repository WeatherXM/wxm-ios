//
//  RewardAnalyticsView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 2/9/24.
//

import SwiftUI

struct RewardAnalyticsView: View {
	@StateObject var viewModel: RewardAnalyticsViewModel

    var body: some View {
		NavigationContainerView {
			ContentView(viewModel: viewModel)
		}
    }
}

private struct ContentView: View {
	@EnvironmentObject var navigationObject: NavigationObject
	@ObservedObject var viewModel: RewardAnalyticsViewModel

	var body: some View {
		VStack {
			Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
		}.onAppear {
			navigationObject.title = LocalizableString.RewardAnalytics.stationRewards.localized
		}
	}

}

#Preview {
	RewardAnalyticsView(viewModel: .init())
}
