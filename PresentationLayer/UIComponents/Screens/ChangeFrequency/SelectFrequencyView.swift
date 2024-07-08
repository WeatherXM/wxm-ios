//
//  SelectFrequencyView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 13/3/23.
//

import SwiftUI
import DomainLayer
import Toolkit

struct SelectFrequencyView: View {
    @Binding var selectedFrequency: Frequency?
    @Binding var isFrequencyAcknowledged: Bool
    var country: String?
    var didSelectFrequencyFromLocation: Bool = false
    var preSelectedFrequency: Frequency?

    var body: some View {
		VStack(alignment: .leading, spacing: CGFloat(.defaultSpacing)) {
            title

            ScrollView {
                ZStack {
                    VStack(alignment: .leading, spacing: 0) {
						VStack(spacing: CGFloat(.mediumSpacing)) {
							text
						
							textLink
								.simultaneousGesture(TapGesture().onEnded {
									WXMAnalytics.shared.trackEvent(.selectContent, parameters: [.contentType: .frequencyDocumentation])
								})
						}

                        frequencyTitle

						VStack(spacing: CGFloat(.mediumSpacing)) {
							frequencyPicker

							frequencyAutoSelectionText
						}
                    }
                }
            }

            Spacer()

            acknowledgementContainer
        }
    }
}

private extension SelectFrequencyView {
    @ViewBuilder
    var title: some View {
        HStack {
            Text(LocalizableString.SelectFrequency.title.localized)
                .font(.system(size: CGFloat(.smallTitleFontSize), weight: .bold))
                .foregroundColor(Color(colorEnum: .darkestBlue))

            Spacer()
        }
    }

    @ViewBuilder
    var text: some View {
        Text(LocalizableString.SelectFrequency.text.localized)
            .font(.system(size: CGFloat(.normalFontSize)))
            .foregroundColor(Color(colorEnum: .text))
    }

    var textLink: some View {
        let linkText = LocalizableString.SelectFrequency.listLinkText.localized
        let url = DisplayedLinks.heliumRegionFrequencies.linkURL
        let link = "**[\(linkText)](\(url))**"

        var actualText = LocalizableString.SelectFrequency.listLink(link).localized.attributedMarkdown ?? ""
        let container = AttributeContainer([.foregroundColor: UIColor(colorEnum: .primary)])
        let range = actualText.range(of: linkText)!
        actualText[range].mergeAttributes(container)

        return Text(actualText)
            .foregroundColor(Color(colorEnum: .text))
            .font(.system(size: CGFloat(.normalFontSize)))
    }

    @ViewBuilder
    var frequencyTitle: some View {
        Text(LocalizableString.SelectFrequency.subtitle.localized)
            .font(.system(size: CGFloat(.normalFontSize), weight: .bold))
            .foregroundColor(Color(colorEnum: .text))
            .padding(.top)
            .padding(.bottom, 4)
    }

    @ViewBuilder
    var frequencyPicker: some View {
        CustomPicker(
            items: Frequency.allCases,
            selectedItem: $selectedFrequency,
            textCallback: { frequencyTitle($0) }
        )
    }

    @ViewBuilder
    var frequencyAutoSelectionText: some View {
        if let currentCountry = country {
            Text(LocalizableString.SelectFrequency.selectedFromLocationDescription(currentCountry.localizedUppercase).localized)
            .font(.system(size: CGFloat(.normalFontSize), weight: .bold))
            .lineSpacing(4)
        } else {
            EmptyView()
        }
    }

    var acknowledgeToggle: some View {
        return Toggle(
            LocalizableString.ClaimDevice.locationAcknowledgeText.localized,
            isOn: $isFrequencyAcknowledged
        )
        .labelsHidden()
        .toggleStyle(WXMToggleStyle.Default)
    }

    var acknowledgeText: some View {
        Text(LocalizableString.SelectFrequency.acknowledgeText.localized)
            .font(.system(size: CGFloat(.normalFontSize)))
            .lineSpacing(4)
            .padding(.bottom)
    }

    var acknowledgementContainer: some View {
        HStack(alignment: .top, spacing: CGFloat(.mediumSpacing)) {
            acknowledgeToggle
            acknowledgeText
        }
    }

    func frequencyTitle(_ frequency: Frequency?) -> String {
        guard let frequency = frequency else {
            return "-"
        }

        guard didSelectFrequencyFromLocation,
              frequency == preSelectedFrequency else {
            return frequency.rawValue
        }

        let autoSelectedText: String
        if let currentCountry = country {
            autoSelectedText = LocalizableString.SelectFrequency.selectedFromCountry(currentCountry.localizedUppercase).localized
        } else {
            autoSelectedText = LocalizableString.SelectFrequency.selectedFromLocation.localized
        }

        return "\(frequency.rawValue)\(autoSelectedText)"
    }
}

struct SelectFrequencyView_Previews: PreviewProvider {
    static var previews: some View {
        SelectFrequencyView(selectedFrequency: .constant(.AU915),
                            isFrequencyAcknowledged: .constant(false),
                            country: "nil",
                            didSelectFrequencyFromLocation: false,
                            preSelectedFrequency: nil)
    }
}
