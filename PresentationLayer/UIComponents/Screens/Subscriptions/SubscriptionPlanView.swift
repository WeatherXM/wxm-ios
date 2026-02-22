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

            VStack(spacing: CGFloat(.smallToMediumSpacing)) {
                HStack {
                    Text(plan.title)
                        .font(.system(size: CGFloat(.largeFontSize), weight: .bold))
                        .foregroundStyle(Color(colorEnum: .text))
                    Spacer()

                    currentPlanView
                }

                trialView

                if let offerText = plan.offer?.offerText {
                    HStack {
                        Text(offerText)
                            .font(.system(size: CGFloat(.largeTitleFontSize), weight: .bold))
                            .foregroundStyle(Color(colorEnum: .darkGrey))
                            .premiumMask(enabled: true,
                                         colors: [Color(colorEnum: .wxmPrimary),
                                                  Color(colorEnum: .betaRewardsPrimary),
                                                  Color(colorEnum: .success)])

                        Spacer()
                    }
                }

                if let price = plan.price {
                    HStack(alignment: .bottom, spacing: CGFloat(.smallSpacing)) {
                        Text(priceAttributedString(price: price, period: plan.period))

                        Spacer()
                    }
                }

                if let subtitle = plan.subtitle {
                    HStack {
                        Text(subtitle)
                            .multilineTextAlignment(.leading)
                            .font(.system(size: CGFloat(.normalFontSize)))
                            .foregroundStyle(Color(colorEnum: .darkGrey))

                        Spacer()
                    }
                }

                WXMDivider()

                VStack(spacing: CGFloat(.smallSpacing)) {
                    if let description = plan.description {
                        HStack {
                            Text(description)
                                .multilineTextAlignment(.leading)
                                .font(.system(size: CGFloat(.normalFontSize)))
                                .foregroundStyle(Color(colorEnum: .darkGrey))

                            Spacer()
                        }
                    }

                    ForEach(plan.bullets, id: \.self) { bullet in
                        HStack(spacing: CGFloat(.smallSpacing)) {
                            Text("•")
                                .font(.fontAwesome(font: .FAPro, size: CGFloat(.normalFontSize)))
                                .foregroundStyle(Color(colorEnum: .darkGrey))
                                .frame(width: 18.0, height: 18.0)
                                .background {
                                    Color(colorEnum: .cryptoOpacity)
                                }
                                .cornerRadius(6.0,
                                              corners: .allCorners)
                                .strokeBorder(color: Color(colorEnum: .darkGrey).opacity(0.2),
                                              lineWidth: 1.0,
                                              radius: 6.0)

                            Text(bullet)
                                .multilineTextAlignment(.leading)
                                .font(.system(size: CGFloat(.normalFontSize)))
                                .foregroundStyle(Color(colorEnum: .darkestBlue))

                            Spacer()
                        }
                    }
                }
            }
            .padding(CGFloat(.mediumSidePadding))
            .background {
                if plan.isPremium {
                    LinearGradient(colors: [Color(colorEnum: .wxmPrimary).opacity(0.12),
                                            Color.clear,
                                            Color(colorEnum: .success).opacity(0.08)],
                                   startPoint: .leading,
                                   endPoint: .trailing)
                }
            }
        }
        .WXMCardStyle(insideHorizontalPadding: 0.0, insideVerticalPadding: 0.0)
        .strokeBorder(color: Color(colorEnum: .cryptoOpacity), lineWidth: 1.0, radius: CGFloat(.cardCornerRadius))
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
        let subtitle: String?
        let offer: Offer?
        let isCurrent: Bool
        let price: String?
        let period: String?
        let description: String?
        let bullets: [String]
        let productId: String?
        let isWarning: Bool
        let isPremium: Bool
    }

    struct Offer: Equatable {
        let offerText: String?
        let trialTitle: String?
        let trialDescription: String?
    }
}

private extension SubscriptionPlanView {
    @ViewBuilder
    var currentPlanView: some View {
        if plan.isPremium, plan.isCurrent {
            Text(LocalizableString.Subscriptions.currentPlan.localized.capitalized)
                .font(.system(size: CGFloat(.caption), weight: .bold))
                .foregroundStyle(Color(colorEnum: .wxmPrimary))
                .padding(.horizontal, CGFloat(.smallToMediumSidePadding))
                .padding(.vertical, CGFloat(.minimumPadding))
                .background {
                    Capsule().foregroundStyle(Color(colorEnum: .wxmPrimary).opacity(0.12))
                }
                .overlay {
                    Capsule().stroke(Color(colorEnum: .wxmPrimary).opacity(0.35),
                                     lineWidth: 1.0)
                }

        } else if plan.isPremium {
            HStack(spacing: CGFloat(.minimumSpacing)) {
                Text(FontIcon.star.rawValue)
                    .font(.fontAwesome(font: .FAProSolid, size: CGFloat(.minimumFontSize)))
                    .foregroundStyle(Color(colorEnum: .wxmPrimary))

                Text(LocalizableString.Subscriptions.bestAccuracy.localized.capitalized)
                    .font(.system(size: CGFloat(.caption), weight: .bold))
                    .foregroundStyle(Color(colorEnum: .wxmPrimary))
            }
            .padding(.horizontal, CGFloat(.smallToMediumSidePadding))
            .padding(.vertical, CGFloat(.minimumPadding))
            .background {
                Capsule().foregroundStyle(Color(colorEnum: .wxmPrimary).opacity(0.12))
            }
            .overlay {
                Capsule().stroke(Color(colorEnum: .wxmPrimary).opacity(0.35),
                                 lineWidth: 1.0)
            }

        } else if plan.isCurrent {
            Text(LocalizableString.Subscriptions.currentPlan.localized.capitalized)
                .font(.system(size: CGFloat(.caption), weight: .bold))
                .foregroundStyle(Color(colorEnum: .darkGrey))
                .padding(.horizontal, CGFloat(.smallToMediumSidePadding))
                .padding(.vertical, CGFloat(.minimumPadding))
                .background {
                    Capsule().foregroundStyle(Color(colorEnum: .cryptoOpacity))
                }
                .overlay {
                    Capsule().stroke(Color(colorEnum: .darkGrey).opacity(0.25),
                                     lineWidth: 1.0)
                }
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

    @ViewBuilder
    var trialView: some View {
        if let trialTitle = plan.offer?.trialTitle,
           let trialDescription = plan.offer?.trialDescription {
            let gradientColors = [Color(colorEnum: .warning),
                                  Color(colorEnum: .betaRewardsPrimary)]

            HStack(spacing: CGFloat(.smallSpacing)) {
                Text(FontIcon.coins.rawValue)
                    .font(.fontAwesome(font: .FAProSolid, size: CGFloat(.largeFontSize)))
                    .foregroundStyle(Color(colorEnum: .warning))

                VStack(alignment: .leading, spacing: 0.0) {
                    Text(trialTitle)
                        .font(.system(size: CGFloat(.normalFontSize), weight: .bold))
                        .premiumMask(enabled: true, colors: gradientColors)

                    Text(trialDescription)
                        .font(.system(size: CGFloat(.caption)))
                        .foregroundStyle(Color(colorEnum: .text))
                }

                Spacer()
            }
            .WXMCardStyle(backgroundColor: .clear)
            .background {
                let gradientColors = [Color(colorEnum: .warning).opacity(0.18),
                                      Color(colorEnum: .betaRewardsPrimary).opacity(0.10)]

                LinearGradient(colors: gradientColors,
                               startPoint: .leading,
                               endPoint: .trailing)
            }
            .cornerRadius(CGFloat(.buttonCornerRadius), corners: .allCorners)
            .overlay {
                let gradientColors = [Color(colorEnum: .warning).opacity(0.60),
                                      Color(colorEnum: .betaRewardsPrimary).opacity(0.40)]

                RoundedRectangle(cornerRadius: CGFloat(.buttonCornerRadius)).stroke(LinearGradient(colors: gradientColors,
                                                                                                 startPoint: .leading,
                                                                                                 endPoint: .trailing))
            }

        }
    }
}

#Preview {
    SubscriptionPlanView(plan: .init(fontIcon: .sparkles,
                                     title: "Free",
                                     subtitle: "Forecasts for general tracking",
                                     offer: .init(offerText: "Limited-time launch offer",
                                                  trialTitle: "2-Month Free Trial",
                                                  trialDescription: "2-month free trial description"),
                                     isCurrent: false,
                                     price: "$0",
                                     period: "per year",
                                     description: "Desc",
                                     bullets: ["24-hour-ahead 3-hourly forecast",
                                               "7-day daily forecast"],
                                     productId: nil,
                                     isWarning: true,
                                     isPremium: true),
                         isSelected: true)
}
