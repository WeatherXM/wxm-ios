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
            tabIcon
        }
    }

    var tabIcon: some View {
        tab.tabIcon
            .renderingMode(.template)
            .foregroundColor(tab == selectedTab ? tab.tabSelected : tab.tabNotSelected)
    }
}
