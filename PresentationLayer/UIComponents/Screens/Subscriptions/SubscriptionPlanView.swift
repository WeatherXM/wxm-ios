//
//  SubscriptionPlanView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 11/1/26.
//

import SwiftUI

struct SubscriptionPlanView: View {
    let plan: Plan
    let isSelected: Bool

    var body: some View {
        HStack(alignment: .top, spacing: CGFloat(.mediumSpacing)) {
            Text(plan.isWarning && isSelected ? FontIcon.warning.rawValue : plan.fontIcon.rawValue)
                .font(.fontAwesome(font: .FAPro, size: CGFloat(.smallTitleFontSize)))
                .foregroundStyle(plan.isWarning && isSelected ? Color(colorEnum: .warning) : Color(colorEnum: .darkGrey))
                .WXMCardStyle(backgroundColor: plan.isWarning && isSelected ? Color(colorEnum: .warningTint) : Color(.layer1),
                              insideHorizontalPadding: CGFloat(.smallToMediumSidePadding),
                              insideVerticalPadding: CGFloat(.smallToMediumSidePadding), cornerRadius: CGFloat(.buttonCornerRadius))


            VStack(spacing: CGFloat(.smallToMediumSpacing)) {
                HStack {
                    Text(plan.title)
                        .font(.system(size: CGFloat(.largeFontSize)))
                        .foregroundStyle(Color(colorEnum: .text))
                    Spacer()

                    if plan.isCurrent {
                        currentPlanView
                    }
                }

                if let price = plan.price {
                    HStack(alignment: .bottom, spacing: CGFloat(.smallSpacing)) {
                        Text(priceAttributedString(price: price, period: plan.period))

                        Spacer()
                    }
                }

                if let freeTrialText = plan.trialText {
                    HStack(alignment: .bottom, spacing: CGFloat(.smallSpacing)) {
                        Text(freeTrialText)
                            .font(.system(size: CGFloat(.normalFontSize)))
                            .foregroundStyle(Color(colorEnum: .success))

                        Spacer()
                    }
                }

                VStack(spacing: CGFloat(.smallSpacing)) {
                    if let description = plan.description {
                        Text(description)
                            .multilineTextAlignment(.leading)
                            .font(.system(size: CGFloat(.normalFontSize)))
                            .foregroundStyle(Color(colorEnum: .text))

                    }

                    ForEach(plan.bullets, id: \.self) { bullet in
                        HStack(spacing: CGFloat(.smallSpacing)) {
                            Text(FontIcon.check.rawValue)
                                .font(.fontAwesome(font: .FAPro, size: CGFloat(.normalFontSize)))
                                .foregroundStyle(Color(colorEnum: .wxmPrimary))

                            Text(bullet)
                                .multilineTextAlignment(.leading)
                                .font(.system(size: CGFloat(.normalFontSize)))
                                .foregroundStyle(Color(colorEnum: .text))

                            Spacer()
                        }
                    }
                }
            }
        }
        .WXMCardStyle()
        .indication(show: .constant(isSelected),
                    borderColor: plan.isWarning ? .warning : .wxmPrimary,
                    bgColor: Color(colorEnum: .wxmPrimary)) {
            EmptyView()
        }

    }
}

extension SubscriptionPlanView {
    struct Plan: Equatable, Identifiable {
        var id: String {
            title + (price ?? "")
        }
        
        let fontIcon: FontIcon
        let title: String
        let isCurrent: Bool
        let price: String?
        let period: String?
        let trialText: String?
        let description: String?
        let bullets: [String]
        let productId: String?
        let isWarning: Bool
    }
}

private extension SubscriptionPlanView {
    @ViewBuilder
    var currentPlanView: some View {
        Text(LocalizableString.Subscriptions.currentPlan.localized.uppercased())
            .font(.system(size: CGFloat(.caption), weight: .bold))
            .foregroundStyle(Color(colorEnum: .text))
            .padding(.horizontal, CGFloat(.smallToMediumSidePadding))
            .padding(.vertical, CGFloat(.minimumPadding))
            .background {
                Capsule().foregroundStyle(Color(colorEnum: .layer1))
            }
    }

    func priceAttributedString(price: String, period: String?) -> AttributedString {
        var priceString = price
        if let period {
            priceString.append(" \(period)")
        }

        let font = UIFont.systemFont(ofSize: CGFloat(.XXLTitleFontSize), weight: .bold)
        var attributedString = AttributedString(priceString)
        attributedString.font = font
        attributedString.foregroundColor = Color(colorEnum: .text)

        if let period, let periodRange = attributedString.range(of: period) {
            let periodFont = UIFont.systemFont(ofSize: CGFloat(.normalFontSize))
            attributedString[periodRange].foregroundColor = Color(colorEnum: .darkGrey)
            attributedString[periodRange].font = periodFont
        }

        return attributedString
    }

}

#Preview {
    SubscriptionPlanView(plan: .init(fontIcon: .sparkles,
                                     title: "Free",
                                     isCurrent: true,
                                     price: "$0",
                                     period: "/year",
                                     trialText: nil,
                                     description: "Desc",
                                     bullets: ["24-hour-ahead 3-hourly forecast",
                                              "7-day daily forecast"],
                                    productId: nil,
                                     isWarning: true),
                         isSelected: true)
}
