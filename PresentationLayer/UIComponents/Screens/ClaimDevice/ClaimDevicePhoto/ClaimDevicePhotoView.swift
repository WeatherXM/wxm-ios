//
//  ClaimDevicePhotoView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 15/7/25.
//

import SwiftUI

struct ClaimDevicePhotoView: View {
	@StateObject var viewModel: ClaimDevicePhotoViewModel

    var body: some View {
		GalleryImagesView(viewModel: viewModel.photosViewModel) {
			Button {
//				viewModel.handleButtonTap()
			} label: {
				Text(LocalizableString.ClaimDevice.uploadAndClaim.localized)
					.padding(.horizontal, CGFloat(.defaultSidePadding))
					.padding(.vertical, CGFloat(.mediumSidePadding))

			}
			.buttonStyle(WXMButtonStyle.filled(fixedSize: true))
		}
    }
}

#Preview {
	ClaimDevicePhotoView(viewModel: ViewModelsFactory.getClaimDevicePhotoGalleryViewModel(linkNavigator: LinkNavigationHelper(),
																						  completion: {}))
}
