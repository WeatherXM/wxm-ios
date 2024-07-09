//
//  AddButton.swift
//  PresentationLayer
//
//  Created by Danae Kikue Dimou on 18/5/22.
//

import SwiftUI

struct AddButton: View {

    var body: some View {
        ZStack {
            Button {
				let viewModel = ViewModelsFactory.getClaimStationSelectionViewModel()
				Router.shared.navigateTo(.claimStationSelection(viewModel))
            } label: {
                Image(asset: .plus)
                    .renderingMode(.template)
                    .foregroundColor(Color(colorEnum: .top))
            }
            .frame(width: CGFloat(.fabButtonsDimension), height: CGFloat(.fabButtonsDimension))
            .background(Color(colorEnum: .wxmPrimary))
            .cornerRadius(CGFloat(.cardCornerRadius))
            .shadow(radius: ShadowEnum.addButton.radius, x: ShadowEnum.addButton.xVal, y: ShadowEnum.addButton.yVal)
        }
    }
}

struct Previews_AddButton_Previews: PreviewProvider {
    static var previews: some View {
        AddButton()
    }
}
