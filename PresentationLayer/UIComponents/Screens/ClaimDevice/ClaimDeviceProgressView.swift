//
//  ClaimDeviceProgressView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 17/5/24.
//

import SwiftUI

struct ClaimDeviceProgressView: View {
	@Binding var state: State

    var body: some View {
		ZStack {
			Color(colorEnum: .newBG)
				.ignoresSafeArea()
			Group {
				switch state {
					case .loading(let title, let subtitle):
						DeviceUpdatesLoadingView(title: title,
												 subtitle: subtitle,
												 currentStepIndex: .constant(nil),
												 progress: .constant(nil))
					case .success(let object):
						SuccessView(obj: object)
					case .fail(let object):
						FailView(obj: object)
				}
			}
			.padding()
		}
    }
}

extension ClaimDeviceProgressView {
	enum State {
		case loading(String, AttributedString)
		case success(FailSuccessStateObject)
		case fail(FailSuccessStateObject)
	}
}

#Preview {
	ClaimDeviceProgressView(state: .constant(.loading("Title", "Subtitle")))
}
