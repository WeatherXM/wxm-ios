//
//  AddButton.swift
//  PresentationLayer
//
//  Created by Danae Kikue Dimou on 18/5/22.
//

import SwiftUI

struct AddButton: View {

	@Binding var showNotification: Bool

    var body: some View {
        ZStack {
            Button {
				showNotification = false
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
			.overlay {
				if  showNotification {
					VStack {
						HStack {
							Spacer()
							Circle()
								.foregroundStyle(Color(colorEnum: .error))
								.frame(width: 12.0, height: 12.0)
						}

						Spacer()
					}
				}
			}
        }
    }
}

struct Previews_AddButton_Previews: PreviewProvider {
    static var previews: some View {
		AddButton(showNotification: .constant(true))
    }
}
