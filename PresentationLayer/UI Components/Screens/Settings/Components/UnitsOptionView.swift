//
//  UnitsOptionView.swift
//  PresentationLayer
//
//  Created by danaekikue on 17/6/22.
//

import SwiftUI

struct UnitsOptionView: View {
    @EnvironmentObject var settingsViewModel: SettingsViewModel

    let option: String
    var unitCase: SettingsEnum
    var isOptionActive: Bool

    var body: some View {
        Button {
            settingsViewModel.setUnits(unitCase: unitCase, chosenOption: option)
            settingsViewModel.isShowingUnitsOverlay = false
        } label: {
            HStack {
                circleRadius
                Text(option)
            }
        }
    }

    var circleRadius: some View {
        CircleRadius(isOptionActive: isOptionActive)
            .padding(.trailing, 10)
    }
}
