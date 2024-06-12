//
//  UpdateFirmwareView+Content.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 3/2/23.
//

import SwiftUI

extension UpdateFirmwareView {
    @ViewBuilder
    var installationView: some View {
		GeometryReader { _ in
			VStack {
				Spacer()
				
				HStack {
					Spacer()

					DeviceUpdatesLoadingView(topTitle: viewModel.topTitle,
											 topSubtitle: viewModel.topSubtitle,
											 title: viewModel.title,
											 subtitle: viewModel.subtile,
											 steps: viewModel.steps,
											 currentStepIndex: $viewModel.currentStepIndex,
											 progress: $viewModel.progress)
					
					Spacer()
				}
			
				Spacer()
			}
		}
    }
}
