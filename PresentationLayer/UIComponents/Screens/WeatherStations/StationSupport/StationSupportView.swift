//
//  StationSupportView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 22/9/25.
//

import SwiftUI
import MarkdownUI

struct StationSupportView: View {
	@StateObject var viewModel: StationSupportViewModel

	var body: some View {
		ScrollView {
			Group {
				if let markdownString = viewModel.markdownString {
					Markdown(markdownString)
				} else {
					Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
				}
			}
			.padding()
		}
		.task {
			viewModel.refresh()
		}
	}
}

#Preview {
	StationSupportView(viewModel: ViewModelsFactory.getStationSupportViewModel(deviceName: ""))
}
