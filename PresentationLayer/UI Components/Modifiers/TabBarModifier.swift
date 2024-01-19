//
//  TabBarModifier.swift
//  PresentationLayer
//
//  Created by Danae Kikue Dimou on 12/5/22.
//

import SwiftUI

struct TabBarModifier: ViewModifier {
    let insideHorizontalTabBarPadding: CGFloat
    let insideVerticalTabBarPadding: CGFloat
    let bottomPaddingTabBarPadding: CGFloat
    let tabBarContainerRadius: CGFloat
    let backgroundColor: Color

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, insideHorizontalTabBarPadding)
            .padding(.vertical, insideVerticalTabBarPadding)
            .background(backgroundColor)
            .cornerRadius(tabBarContainerRadius)
            .padding(.bottom, bottomPaddingTabBarPadding)
            .shadow(radius: ShadowEnum.tabBar.radius, x: ShadowEnum.tabBar.xVal, y: ShadowEnum.tabBar.yVal)
    }
}

extension View {
    func tabBarStyle(
        insideHorizontalTabBarPadding: CGFloat = CGFloat(.largeSidePadding),
        insideVerticalTabBarPadding: CGFloat = CGFloat(.mediumSidePadding),
        bottomPaddingTabBarPadding: CGFloat = CGFloat(.largeSidePadding),
        tabBarContainerRadius: CGFloat = CGFloat(.tabBarCornerRadius),
        backgroundColor: Color = Color(colorEnum: .top)
    ) -> some View { modifier(
        TabBarModifier(
            insideHorizontalTabBarPadding: insideHorizontalTabBarPadding,
            insideVerticalTabBarPadding: insideVerticalTabBarPadding,
            bottomPaddingTabBarPadding: bottomPaddingTabBarPadding,
            tabBarContainerRadius: tabBarContainerRadius,
            backgroundColor: backgroundColor
        )
    )
    }
}
