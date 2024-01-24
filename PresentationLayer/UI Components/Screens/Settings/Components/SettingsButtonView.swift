//
//  SettingsButtonView.swift
//  PresentationLayer
//
//  Created by danaekikue on 17/6/22.
//

import SwiftUI

struct SettingsButtonView: View {
    let settingsCase: SettingsEnum
    let settingCaption: String
	let isToggleInteractionEnabled: Bool
    @Binding var unitCaseModal: SettingsEnum
    @Binding var isShowingUnitsOverlay: Bool
    @Binding var switchValue: Bool?
    var action: () -> Void

    init(settingsCase: SettingsEnum, 
		 settingCaption: String,
		 isToggleInteractionEnabled: Bool = true,
         unitCaseModal: Binding<SettingsEnum> = .constant(.temperature),
         isShowingUnitsOverlay: Binding<Bool> = .constant(false),
         switchValue: Binding<Bool?> = .constant(nil),
         action: @escaping () -> Void = {}) {
        self.settingsCase = settingsCase
        self.settingCaption = settingCaption
		self.isToggleInteractionEnabled = isToggleInteractionEnabled
        _unitCaseModal = unitCaseModal
        _isShowingUnitsOverlay = isShowingUnitsOverlay
        self.action = action
        _switchValue = switchValue
    }

    var body: some View {
        Button {
            action()
            isShowingUnitsOverlay = true
            unitCaseModal = settingsCase
        } label: {
            settingsButton
        }
    }

    var settingsButton: some View {
        HStack {
            VStack(alignment: .leading) {
                title
                if !settingCaption.isEmpty {
                    caption
                }
            }
            Spacer()

            if let switchValue {
                Toggle("", isOn: Binding(get: { switchValue }, set: { self.switchValue = $0 }))
                .labelsHidden()
                .toggleStyle(
                    WXMToggleStyle.Default
                )
				.disabled(!isToggleInteractionEnabled)
            }
        }
        .contentShape(Rectangle())
    }

    var title: some View {
        Text(settingsCase.settingsTitle)
            .font(.system(size: CGFloat(.largeTitleFontSize)))
            .foregroundColor(Color(colorEnum: .text))
            .multilineTextAlignment(.leading)
    }

    var caption: some View {
        Text(settingCaption)
            .font(.system(size: CGFloat(.normalFontSize)))
            .foregroundColor(Color(colorEnum: .darkGrey))
            .multilineTextAlignment(.leading)
    }
}
