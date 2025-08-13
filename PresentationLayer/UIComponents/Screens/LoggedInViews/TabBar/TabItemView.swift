//
//  TabViewItem.swift
//  PresentationLayer
//
//  Created by Danae Kikue Dimou on 11/5/22.
//

import SwiftUI

struct TabItemView: View {
    let tab: TabSelectionEnum
    @Binding var selectedTab: TabSelectionEnum

    var body: some View {
        tabItem
    }

    var tabItem: some View {
        Button {
            selectedTab = tab
        } label: {
			VStack(spacing: CGFloat(.minimumSpacing)) {
				tabIcon
				tabText
			}
        }
    }

    var tabIcon: some View {
		Text(tab.tabIcon.rawValue)
			.font(.fontAwesome(font: .FAProSolid,
							   size: CGFloat(.smallTitleFontSize)))
			.foregroundColor(tab == selectedTab ? tab.tabSelected : tab.tabNotSelected)
    }

	var tabText: some View {
		Text(tab.tabTitle)
			.font(.system(size: CGFloat(.caption)))
			.foregroundColor(tab == selectedTab ? tab.tabSelected : tab.tabNotSelected)
	}
}
