//
//  TapBarView.swift
//  PresentationLayer
//
//  Created by Danae Kikue Dimou on 11/5/22.
//

import SwiftUI

struct TabBarView: View {
    @Binding var selectedTab: TabSelectionEnum
    let isProfileTabNotificationIconShowing: Bool
    private let itemsSpacing = 70.0

    public init(_ selectedTab: Binding<TabSelectionEnum>, _ isProfileTabNotificationIconShowing: Bool) {
        _selectedTab = selectedTab
        self.isProfileTabNotificationIconShowing = isProfileTabNotificationIconShowing
    }

    var body: some View {
        tabBar.tabBarStyle()
    }

    var tabBar: some View {
		LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3)) {
            ForEach(TabSelectionEnum.allCases, id: \.self) { tab in
                tabIcon(tab: tab)
            }
	    }
    }

    func tabIcon(tab: TabSelectionEnum) -> some View {
        ZStack {
            TabItemView(tab: tab, selectedTab: $selectedTab)
				.overlay {
					if tab == TabSelectionEnum.profileTab {
						VStack {
							Image(asset: .badge)
								.padding(.leading, CGFloat(.defaultSidePadding))
								.opacity(isProfileTabNotificationIconShowing ? 1 : 0)

							Spacer()
						}
					}
				}
        }
    }
}

struct Previews_TabBarView_Previews: PreviewProvider {
    static var previews: some View {
		ZStack {
			Color(colorEnum: .blueTint)
			TabBarView(.constant(.homeTab), true)
		}
    }
}
