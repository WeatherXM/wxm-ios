//
//  LazyLoadingPagerView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 13/9/23.
//

import SwiftUI

struct LazyLoadingPagerView<Content: View, Data: Hashable>: View {
    @Binding var data: Data
    let initialContent: (Data) -> Content
    let previous: (Data) -> Content?
    let next: (Data) -> Content?
    let previousData: (Data) -> Data?
    let nextData: (Data) -> Data?
    let scrollDirection: (Data, Data) -> UIPageViewController.NavigationDirection

    var body: some View {
        PagerView(data: $data,
                  content: initialContent,
                  previous: previous,
                  next: next,
                  previousData: previousData,
                  nextData: nextData,
                  scrollDirection: scrollDirection)
		.navigationBarHidden(true)
    }
}

#Preview {
    ZStack {
        Color.red.ignoresSafeArea()

        LazyLoadingPagerView(data: .constant(0)) { data in
            Text("\(data)")
        } previous: { data in
            Text("\(data-1)")
        } next: { data in
            Text("\(data+1)")
        } previousData: { data in
            data - 1
        } nextData: { data in
            data + 1
        } scrollDirection: { _, _ in
                .forward
        }
    }
}

private struct PagerView<Content: View, Data: Hashable>: UIViewControllerRepresentable {

    @Binding var data: Data
    let content: (Data) -> Content
    let previous: (Data) -> Content?
    let next: (Data) -> Content?
    let previousData: (Data) -> Data?
    let nextData: (Data) -> Data?
    let scrollDirection: (Data, Data) -> UIPageViewController.NavigationDirection

    func makeUIViewController(context: Context) -> UIPageViewController {
        let vc = UIPageViewController(transitionStyle: .scroll,
                                      navigationOrientation: .horizontal)
        vc.view.backgroundColor = .clear
        vc.delegate = context.coordinator
        vc.dataSource = context.coordinator

        let initialController =  PagerHostingController<Content, Data>.getController(data: data, view: content(data))
        vc.setViewControllers([initialController], direction: .forward, animated: false)

        return vc
    }

    func makeCoordinator() -> PagerCoordinator<Content, Data> {
        PagerCoordinator(dataSource: DataSource(data: $data,
                                                content: content,
                                                previous: previous,
                                                next: next,
                                                previousData: previousData,
                                                nextData: nextData))
    }

    func updateUIViewController(_ uiViewController: UIPageViewController,
                                context: Context) {
        guard let visibleController = uiViewController.viewControllers?.first as? PagerHostingController<Content, Data>,
              let visibleData = visibleController.data,
              visibleData != data else {
            return
        }

        let controller = PagerHostingController<Content, Data>.getController(data: data, view: content(data))
        let direction = scrollDirection(visibleData, data)
        uiViewController.setViewControllers([controller], direction: direction, animated: true)
    }
}

extension PagerView {
    class PagerCoordinator<ContentView: View, ContentData: Hashable>: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

        let dataSource: DataSource<Content, Data>

        init(dataSource: DataSource<Content, Data>) {
            self.dataSource = dataSource
        }

        func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
            guard let viewController = viewController as? PagerHostingController<Content, Data>,
                  let currentData = viewController.data,
                  let view = dataSource.previous(currentData) else {
                return nil
            }

            let previousController = PagerHostingController<Content, Data>.getController(data: dataSource.previousData(currentData), view: view)
            return previousController
        }

        func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
            guard let viewController = viewController as? PagerHostingController<Content, Data>,
                  let currentData = viewController.data,
                  let view = dataSource.next(currentData) else {
                return nil
            }

            let nextController = PagerHostingController<Content, Data>.getController(data: dataSource.nextData(currentData), view: view)
            return nextController
        }

        func pageViewController(_ pageViewController: UIPageViewController,
								didFinishAnimating finished: Bool,
								previousViewControllers: [UIViewController],
								transitionCompleted completed: Bool) {
            guard completed,
                  let visibleController = pageViewController.viewControllers?.first as? PagerHostingController<Content, Data>,
                  let visibleData = visibleController.data else {
                return
            }

            dataSource.data = visibleData
        }
    }

    class DataSource<ContentView: View, ContentData: Hashable> {
        @Binding var data: ContentData
        let content: (ContentData) -> ContentView
        let previous: (ContentData) -> ContentView?
        let next: (ContentData) -> ContentView?
        let previousData: (ContentData) -> ContentData?
        let nextData: (ContentData) -> ContentData?

        init(data: Binding<ContentData>,
             content: @escaping (ContentData) -> ContentView,
             previous: @escaping (ContentData) -> ContentView?,
             next: @escaping (ContentData) -> ContentView?,
             previousData: @escaping (ContentData) -> ContentData?,
             nextData: @escaping (ContentData) -> ContentData?) {
            self._data = data
            self.content = content
            self.previous = previous
            self.next = next
            self.previousData = previousData
            self.nextData = nextData
        }
    }

}

private class PagerHostingController<Content: View, Data: Hashable>: UIHostingController<Content> {

    static func getController(data: Data?, view: Content) -> PagerHostingController<Content, Data> {
        let controller = PagerHostingController<Content, Data>(rootView: view)
        controller.view.backgroundColor = .clear
        controller.data = data
        return controller
    }
    
    var data: Data?

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		guard #available(iOS 16.0, *) else {
			/// This fixes the issue with navigation bar while swipping in iOS 15
			navigationController?.setNavigationBarHidden(true, animated: false)
			return
		}

	}
}
