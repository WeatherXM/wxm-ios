//
//  TabBarModifier.swift
//  PresentationLayer
//
//  Created by Danae Kikue Dimou on 12/5/22.
//

import SwiftUI

struct TabBarModifier: ViewModifier {
    let insideHorizontalTabBarPadding: CGFloat
    let insideTopTabBarPadding: CGFloat
	let insideBottomTabBarPadding: CGFloat
    let backgroundColor: Color

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, insideHorizontalTabBarPadding)
			.padding(.top, insideTopTabBarPadding)
			.padding(.bottom, insideBottomTabBarPadding)
			.background(backgroundColor.ignoresSafeArea())
    }
}

extension View {
    func tabBarStyle(
		insideHorizontalTabBarPadding: CGFloat = 0.0,
		insideTopTabBarPadding: CGFloat = CGFloat(.smallToMediumSidePadding),
		insideBottomTabBarPadding: CGFloat = CGFloat(.defaultSidePadding),
        backgroundColor: Color = Color(colorEnum: .top)
    ) -> some View { modifier(
        TabBarModifier(
            insideHorizontalTabBarPadding: insideHorizontalTabBarPadding,
            insideTopTabBarPadding: insideTopTabBarPadding,
			insideBottomTabBarPadding: insideBottomTabBarPadding,
            backgroundColor: backgroundColor
        )
    )
    }
}
