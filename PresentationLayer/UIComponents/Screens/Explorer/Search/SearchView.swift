//
//  SearchView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 20/6/23.
//

import SwiftUI
import Toolkit

struct SearchView: View {
    @StateObject var viewModel: ExplorerSearchViewModel
	var showNoActiveView: Bool = true
    @FocusState var isFocused: Bool
    /// This state variable is injected in Textfields becauses assigning directy the view model's property `searchTerm`
    /// causes a bug with multiple changes callback even if the term doesn't change
    @State var term: String = ""
    @State var showOptionsPopOver = false
	@State var topControlsSize: CGSize = .zero

    var body: some View {
        ZStack {
			if showNoActiveView {
				nonActiveView
			}

            if viewModel.isSearchActive {
                activeView
                    .transition(AnyTransition.opacity.animation(.easeIn(duration: 0.2)))
                    .onAppear {
                        isFocused = true
                    }
                    .onChange(of: term) { newValue in
                        // Assign the updated term to perform the search request
                        viewModel.updateSearchTerm(newValue)
                    }
            }
        }
		.wxmAlert(show: $showOptionsPopOver, shouldDismissOnTapOutside: true) {
			VStack {
				ExplorerPopoverView(show: $showOptionsPopOver,
									viewModel: viewModel)
				.padding(.horizontal, CGFloat(.mediumSidePadding))
				.padding(.top, topControlsSize.height)
				Spacer()
			}
			.iPadMaxWidth()
		}
		.onAppear {
			WXMAnalytics.shared.trackScreen(.networkSearch)
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.gray
                .ignoresSafeArea()
            SearchView(viewModel: ViewModelsFactory.getNetworkSearchViewModel())
        }
    }
}
