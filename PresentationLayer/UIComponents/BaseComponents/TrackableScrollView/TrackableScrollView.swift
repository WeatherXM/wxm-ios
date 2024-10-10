//
//  TrackableScrollView.swift
//  PresentationLayer
//
//  Created by Hristos Condrea on 31/5/22.
//

import PullableScrollView
import SwiftUI
import Toolkit

struct TrackableScrollView<Content>: View where Content: View {
    private let showIndicators: Bool
    private let refreshAction: PullableScrollView<Content>.RefreshCallback?
    private let content: () -> Content
    private var offsetObject: TrackableScrollOffsetObject?

    /// A refreshable scroll view which tracks the offset and content size
    /// - Parameters:
    ///   - showIndicators: Show or hide scrolling indicators
    ///   - offsetObject: Object which keeps the `contentOffset` and the `contentSize`.
	///    User of this component should keep a reference to this object in order to get the content offset and size changes
    ///   - refreshAction: Callback where the refresh actions should be performed. Once every request is finished call the passed callback to hide refresh control
    ///   - content: The content to be presented in scroll view
    init(showIndicators: Bool = true,
		 offsetObject: TrackableScrollOffsetObject? = nil,
		 refreshAction: PullableScrollView<Content>.RefreshCallback? = nil,
		 @ViewBuilder content: @escaping () -> Content) {
        self.showIndicators = showIndicators
        self.refreshAction = refreshAction
        self.content = content
        self.offsetObject = offsetObject
    }

    var body: some View {
        GeometryReader { outsideProxy in
            container {
                ZStack {
					if offsetObject != nil {
						GeometryReader { insideProxy in
							Color.clear
								.preference(key: ScrollOffsetPreferenceKey.self, value: [self.calculateContentOffset(fromOutsideProxy: outsideProxy, insideProxy: insideProxy)])
						}
					}

                    self.content()
						.modify { view in
							if let offsetObject {
								view
									.sizeObserver(size: Binding(get: { offsetObject.contentSize }, set: { offsetObject.contentSize = $0 }))
							} else {
								view
							}
						}
                }
            }
			.frame(width: outsideProxy.size.width)
			.modify { view in
				if let offsetObject {
					view
						.sizeObserver(size: Binding(get: { offsetObject.scrollerSize }, set: { offsetObject.scrollerSize = $0 }))
				} else {
					view
				}
			}
            .onTapGesture {}
            .simultaneousGesture(LongPressGesture(minimumDuration: 0.0).onEnded { _ in
                offsetObject?.didStartDragging()
            })
        }
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
            DispatchQueue.main.async {
                self.offsetObject?.contentOffset = value[0]
            }
        }
    }

    private func calculateContentOffset(fromOutsideProxy outsideProxy: GeometryProxy, insideProxy: GeometryProxy) -> CGFloat {
        outsideProxy.frame(in: .global).minY - insideProxy.frame(in: .global).minY
    }

    /// Embeds the content in `PullableScrollView` if `refreshAction` is provided or a regular `ScrollView` if not
    /// - Parameter content: The conent to show
    /// - Returns: The updated view
    @ViewBuilder private func container<ContentView: View>(content: () -> ContentView) -> some View {
        if #available(iOS 16.0, *) {
            ScrollView(showsIndicators: false) {
                content()
            }
            .modify { view in
                if refreshAction != nil {
                    view.refreshable {
                        await refresh()
                    }
                } else {
                    view
                }
            }
            .onAppear {
                UIRefreshControl.appearance().tintColor = UIColor(Color(colorEnum: .wxmPrimary))
            }
        } else if let refreshAction = refreshAction {
            PullableScrollView(tintColor: Color(colorEnum: .wxmPrimary)) { completion in
                refreshAction(completion)
            } content: {
                content()
            }
            .modify { view in
                if #available(iOS 16.0, *) {
                    view.scrollContentBackground(.hidden)
                } else {
                    view.background(Color(colorEnum: .bg))
                }
            }
        } else {
            ScrollView(showsIndicators: false) {
                content()
            }
        }
    }

    private func refresh() async {
        return await withCheckedContinuation { continuation in
            DispatchQueue.main.async {
                self.refreshAction? {
                    continuation.resume()
                }
            }
        }
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    typealias Value = [CGFloat]

    static var defaultValue: [CGFloat] = [0]

    static func reduce(value: inout [CGFloat], nextValue: () -> [CGFloat]) {
        value.append(contentsOf: nextValue())
    }
}

class TrackableScrollOffsetObject: ObservableObject {
    @Published var contentOffset: CGFloat = 0.0 {
        didSet {
            updateDiffOffset()
        }
    }
    @Published private(set) var diffOffset: CGFloat = 0.0
    var contentSize: CGSize = .zero
    var scrollerSize: CGSize = .zero
    var willStartDraggingAction: VoidCallback?

    private var initialOffset: CGFloat?

    func hasReachedBottom(with offset: CGFloat) -> Bool {
        guard contentSize.height >= scrollerSize.height else {
            return false
        }

        return (contentSize.height - offset) <= scrollerSize.height
    }

    fileprivate func didStartDragging() {
        willStartDraggingAction?()
        initialOffset = contentOffset
    }

    private func updateDiffOffset() {
        guard let initialOffset else {
            return
        }

        diffOffset = contentOffset - initialOffset
    }
}
