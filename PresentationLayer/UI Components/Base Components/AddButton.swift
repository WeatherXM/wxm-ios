//
//  AddButton.swift
//  PresentationLayer
//
//  Created by Danae Kikue Dimou on 18/5/22.
//

import SwiftUI

struct AddButton: View {
    @State private var isShowingAddDeviceSheet = false

    var body: some View {
        ZStack {
            Button {
                isShowingAddDeviceSheet.toggle()
            } label: {
                Image(asset: .plus)
                    .renderingMode(.template)
                    .foregroundColor(Color(colorEnum: .top))
            }
            .frame(width: CGFloat(.fabButtonsDimension), height: CGFloat(.fabButtonsDimension))
            .background(Color(colorEnum: .primary))
            .cornerRadius(CGFloat(.cardCornerRadius))
            .shadow(radius: ShadowEnum.addButton.radius, x: ShadowEnum.addButton.xVal, y: ShadowEnum.addButton.yVal)
            .customSheet(
                isPresented: $isShowingAddDeviceSheet
            ) { controller in
                SelectDeviceTypeView(
                    dismiss: controller.dismiss,
                    didSelectClaimFlow: { flow in
                        controller.dismiss()
                        switch flow {
                            case .manual:
                                Router.shared.navigateTo(.claimDevice(false))
                            case .bluetooth:
                                Router.shared.navigateTo(.claimDevice(true))
                        }
                    }
                )
            }
        }
    }
}

struct Previews_AddButton_Previews: PreviewProvider {
    static var previews: some View {
        AddButton()
    }
}
