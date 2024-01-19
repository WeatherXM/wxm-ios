//
//  UnitsOptionsModalView.swift
//  PresentationLayer
//
//  Created by danaekikue on 17/6/22.
//

import SwiftUI

struct UnitsOptionsModalView: View {
    @ObservedObject var settingsViewModel: SettingsViewModel
	private let mainScreenViewModel: MainScreenViewModel = .shared

    var body: some View {
        ZStack {
            if settingsViewModel.isShowingUnitsOverlay {
                Color.black.opacity(0.6)
                    .onTapGesture {
                        settingsViewModel.isShowingUnitsOverlay = false
                    }
                    .ignoresSafeArea()
                    .transition(AnyTransition.opacity.animation(.easeIn(duration: 0.2)))
                    .zIndex(0)

                modalContainer
                    .transition(AnyTransition.scale.animation(.easeIn(duration: 0.2)))
                    .zIndex(1)

            }
        }
    }

    var modalContainer: some View {
        VStack(alignment: .leading) {
            modalTitle
            unitOptions
            cancelButton
        }
        .WXMCardStyle()
        .padding(.horizontal, 10)
    }

    var modalTitle: some View {
        Text(settingsViewModel.unitCaseModal.settingsTitle)
            .font(.system(size: CGFloat(.mediumFontSize), weight: .bold))
            .foregroundColor(Color(colorEnum: .text))
    }

    var unitOptions: some View {
        settingsViewModel.getUnitOptions(mainScreenViewmodel: mainScreenViewModel)
            .padding(.bottom, 16)
    }

    var cancelButton: some View {
        HStack {
            Spacer()
            Button {
                settingsViewModel.isShowingUnitsOverlay = false
            } label: {
                Text(LocalizableString.cancel.localized)
                    .foregroundColor(Color(colorEnum: .primary))
            }
        }
    }
}
