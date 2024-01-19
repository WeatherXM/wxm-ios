//
//  UpdateFirmwareView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 3/2/23.
//

import PresentationLayer
import SwiftUI

struct UpdateFirmwareView: View {
    @StateObject var viewModel: UpdateFirmwareViewModel
    @State var stepsViewSize: CGSize = .zero

    var body: some View {
        switch viewModel.state {
        case .installing:
            installationView
        case let .failed(obj):
            FailView(title: obj.title,
                     subtitle: obj.subtitle,
                     cancelButtonTitle: obj.cancelTitle ?? "",
                     retryButtonTitle: obj.retryTitle ?? "",
                     cancelAction: obj.cancelAction ?? {},
                     retryButtonAction: obj.retryAction ?? {})
        case let .success(obj):
            SuccessView(title: obj.title,
                        subtitle: obj.subtitle,
                        buttonTitle: obj.retryTitle ?? "",
                        buttonAction: obj.retryAction ?? {})
        }
    }
}

struct UpdateFirmwareView_Previews: PreviewProvider {
    static var previews: some View {
        UpdateFirmwareView(viewModel: UpdateFirmwareViewModel.mockInstance)
    }
}

struct UpdateFirmwareViewSuccess_Previews: PreviewProvider {
    static var previews: some View {
        UpdateFirmwareView(viewModel: UpdateFirmwareViewModel.successMockInstance)
            .padding()
    }
}

struct UpdateFirmwareViewError_Previews: PreviewProvider {
    static var previews: some View {
        UpdateFirmwareView(viewModel: UpdateFirmwareViewModel.errorMockInstance)
            .padding()
    }
}
