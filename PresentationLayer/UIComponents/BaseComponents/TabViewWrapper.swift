//
//  TabViewWrapper.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 22/8/23.
//

// Implementation on bugs...
// The following wrapper solves the memory leaks in SwiftUI's TabView
// https://stackoverflow.com/questions/62857076/memory-leak-in-tabview-with-pagetabviewstyle
import SwiftUI

struct TabViewWrapper<Content: View, Selection: Hashable>: View {
    @Binding var selection: Selection
	@ViewBuilder let content: () -> Content
	/// Observe the color scheme in order to solve a bug while switching themes.
	/// For some reason, the content of the tab view doesn't propagate the theme changes to its children	
	@Environment(\.colorScheme) var colorScheme

    var body: some View {
        TabView(selection: $selection, content: content)
			.id(colorScheme)
    }
}
