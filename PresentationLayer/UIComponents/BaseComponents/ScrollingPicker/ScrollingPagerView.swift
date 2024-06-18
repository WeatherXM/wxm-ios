//
//  ScrollingPickerView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 7/9/23.
//

import SwiftUI
import Toolkit

struct ScrollingPickerView: View {
    @Binding var selectedIndex: Int
    let textCallback: GenericValueCallback<Int, String>
    let countCallback: GenericValueWithNoArgumentCallback<Int>

    var body: some View {
        VStack(spacing: 0.0) {
            GeometryReader { proxy in
                Pager(selectedIndex: $selectedIndex,
                      containerSize: proxy.size,
                      textCallback: textCallback,
                      countCallback: countCallback)
				.clipped()
            }
            .frame(height: 40.0)

            Color(colorEnum: .text)
                .frame(width: 100.0, height: 2.0)
        }
        .overlay {
			LinearGradient(gradient: Gradient(colors: [Color(colorEnum: .top),
													   Color(colorEnum: .top).opacity(0.1),
													   Color.clear,
													   Color(colorEnum: .top).opacity(0.1),
                                                       Color(colorEnum: .top)]),
						   startPoint: .leading,
						   endPoint: .trailing)
            .allowsHitTesting(false)
        }
    }
}

private let cellId = "identifier"
private struct Pager: UIViewRepresentable {

    @Binding var selectedIndex: Int
    let containerSize: CGSize
    let textCallback: GenericValueCallback<Int, String>
    let countCallback: GenericValueWithNoArgumentCallback<Int>

    func makeCoordinator() -> Coordinator {
        Coordinator(valueForIndexCallback: textCallback,
                    didSelectCallback: { index in selectedIndex = index },
                    elementsCountCallback: countCallback)
    }

    func makeUIView(context: Self.Context) -> UICollectionView {
        let flowlayout = PagingCollectionViewLayout()
        flowlayout.scrollDirection = .horizontal
        flowlayout.itemSize = CGSize(width: containerSize.width / 2.0, height: 40.0)
		flowlayout.minimumLineSpacing = 0.0

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowlayout)
        collectionView.register(PagerCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = context.coordinator
        collectionView.delegate = context.coordinator
        collectionView.decelerationRate = .fast
        collectionView.backgroundColor = .clear
        return collectionView
    }

    func updateUIView(_ uiView: UICollectionView, context: Self.Context) {
        context.coordinator.size = containerSize
        uiView.reloadData()
        print(selectedIndex)
        context.coordinator.selectElement(selectedIndex, in: uiView)
    }
}

extension Pager {
    class Coordinator: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
        let valueForIndexCallback: GenericValueCallback<Int, String>
        let didSelectCallback: GenericCallback<Int>
        let elementsCountCallback: GenericValueWithNoArgumentCallback<Int>
        var size: CGSize = .zero

        init(valueForIndexCallback: @escaping GenericValueCallback<Int, String>,
             didSelectCallback: @escaping GenericCallback<Int>,
             elementsCountCallback: @escaping GenericValueWithNoArgumentCallback<Int>) {
            self.valueForIndexCallback = valueForIndexCallback
            self.didSelectCallback = didSelectCallback
            self.elementsCountCallback = elementsCountCallback
        }

        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            guard section == 1 else {
                return 1
            }

            return elementsCountCallback()
        }

        func numberOfSections(in collectionView: UICollectionView) -> Int {
            3
        }

        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! PagerCell

            guard indexPath.section == 1 else {
                cell.label.text = nil
                return cell
            }

            cell.label.text = valueForIndexCallback(indexPath.row)
            cell.label.sizeToFit()

            return cell
        }

        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            didSelectCallback(indexPath.row)
        }

        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            guard indexPath.section == 1 else {
                return CGSize(width: size.width / 4.0, height: 40.0)
            }
            return CGSize(width: size.width / 2.0, height: 40.0)
        }

        func selectElement(_ index: Int, in collectionView: UICollectionView) {
			/// Dispatch on main thread to make sure will be scrolled as expected
			/// The main reason for this was an issue in scroll position on appear
			DispatchQueue.main.async { [weak collectionView] in
				guard let collectionView,
					  collectionView.numberOfSections > 2 else {
					return
				}
				let indexPath = IndexPath(row: index, section: 1)
				collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
			}
        }

        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            guard let collectionView = scrollView as? UICollectionView,
                  let center = collectionView.superview?.convert(collectionView.center, to: collectionView),
                  let indexPath = collectionView.indexPathForItem(at: center) else {
                return
            }

            didSelectCallback(indexPath.row)
        }
    }

    class PagingCollectionViewLayout: UICollectionViewFlowLayout {

        var velocityThresholdPerPage: CGFloat = 2
        var numberOfItemsPerPage: CGFloat = 1

        override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
            guard let collectionView = collectionView else { return proposedContentOffset }

            let pageLength: CGFloat
            let approxPage: CGFloat
            let currentPage: CGFloat
            let speed: CGFloat

            if scrollDirection == .horizontal {
                pageLength = (self.itemSize.width + self.minimumLineSpacing) * numberOfItemsPerPage
                approxPage = collectionView.contentOffset.x / pageLength
                speed = velocity.x
            } else {
                pageLength = (self.itemSize.height + self.minimumLineSpacing) * numberOfItemsPerPage
                approxPage = collectionView.contentOffset.y / pageLength
                speed = velocity.y
            }

            if speed < 0 {
                currentPage = ceil(approxPage)
            } else if speed > 0 {
                currentPage = floor(approxPage)
            } else {
                currentPage = round(approxPage)
            }

            guard speed != 0 else {
                if scrollDirection == .horizontal {
                    return CGPoint(x: currentPage * pageLength, y: 0)
                } else {
                    return CGPoint(x: 0, y: currentPage * pageLength)
                }
            }

            var nextPage: CGFloat = currentPage + (speed > 0 ? 1 : -1)

            let increment = speed / velocityThresholdPerPage
            nextPage += (speed < 0) ? ceil(increment) : floor(increment)

            if scrollDirection == .horizontal {
                return CGPoint(x: nextPage * pageLength, y: 0)
            } else {
                return CGPoint(x: 0, y: nextPage * pageLength)
            }
        }
    }

    class PagerCell: UICollectionViewCell {
        let label: UILabel

        override init(frame: CGRect) {
            label = UILabel()
            label.textColor = UIColor(colorEnum: .text)
            label.font = UIFont.systemFont(ofSize: CGFloat(.mediumFontSize), weight: .bold)
            label.textAlignment = .center
            super.init(frame: frame)
            label.translatesAutoresizingMaskIntoConstraints = false
            self.contentView.addSubview(label)
            label.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0).isActive = true
            label.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0).isActive = true
            label.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0).isActive = true
            label.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0).isActive = true
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
