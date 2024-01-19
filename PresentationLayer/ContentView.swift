//
//  ContentView.swift
//  PresentationLayer
//
//  Created by Hristos Condrea on 6/5/22.
//

import SwiftUI

public struct ContentView: View {
    @State var isSignInViewEnabled = true
    @State var selectedTab: TabSelectionEnum = .homeTab

    public init() {}

    public var body: some View {
        WeatherStationsHomeView(selectedTab: $selectedTab)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
