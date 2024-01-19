//
//  TabViewWrapper.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 22/8/23.
//

/// Implementation on bugs...
/// The following wrapper solves the memory leaks in SwiftUI's TabView
/// https://stackoverflow.com/questions/62857076/memory-leak-in-tabview-with-pagetabviewstyle
import SwiftUI

struct TabViewWrapper<Content: View, Selection: Hashable>: View {
    @Binding var selection: Selection
    @ViewBuilder let content: () -> Content

    var body: some View {
        TabView(selection: $selection, content: content)
    }
}
