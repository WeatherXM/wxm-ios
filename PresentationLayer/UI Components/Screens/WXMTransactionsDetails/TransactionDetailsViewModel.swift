//
//  TransactionDetailsViewModel.swift
//  PresentationLayer
//
//  Created by Danae Kikue Dimou on 12/9/22.
//

import Combine
import DomainLayer
import struct SwiftUI.CGFloat
import UIKit
import Toolkit

final class TransactionDetailsViewModel: ObservableObject {
    private let tokenUseCase: TokenUseCase

    private static let FETCH_INTERVAL_MONTHS = 3

    private var cancellableSet: Set<AnyCancellable> = []
	private var pendingTask: Task<(), Never>? {
		didSet {
			isRequestInProgress = pendingTask != nil
		}
	}
	private var data: [NetworkDeviceRewardsSummary] = []

    weak var mainVM: MainScreenViewModel?
	@Published var isRequestInProgress: Bool = false
    @Published var transactions = [[NetworkDeviceRewardsSummary]]()
    @Published var showFullScreenLoader = false
    let scrollOffsetObject: TrackableScrollOffsetObject = .init()

    @Published var navigationTitle: String = ""
    @Published var isFailed: Bool = false
    private(set) var failObj: FailSuccessStateObject?
    let device: DeviceDetails
	let followState: UserDeviceFollowState?
	var errorIndicationButtonTitle: String {
		followState?.relation == .owned ? LocalizableString.StationDetails.ownedRewardsErrorButtonTitle.localized : LocalizableString.StationDetails.rewardsErrorButtonTitle.localized
	}
	private var pagination: TransactionsPagination

	init(device: DeviceDetails, followState: UserDeviceFollowState?, tokenUseCase: TokenUseCase) {
        self.device = device
		self.followState = followState
        self.tokenUseCase = tokenUseCase
		self.pagination = .init(device: device, transactionsObject: nil, currentPage: 0)
		
		refresh(showFullScreenLoader: true, reset: true)
    }
	
	/// Fetches new page and updates the data source
	/// - Parameters:
	///   - showFullScreenLoader: If `true` shows full screen loader
	///   - reset: If `true` resets the data source and fetches the first page
	///   - completion: Called once the request is finished
	func refresh(showFullScreenLoader: Bool, reset: Bool, completion: (() -> Void)? = nil) {
		guard pendingTask == nil else {
			return
		}

		self.showFullScreenLoader = showFullScreenLoader

		if reset {
			self.pagination = .init(device: device, transactionsObject: nil, currentPage: 0)
		}

		pendingTask = Task { @MainActor [weak self] in
			guard let self else {
				return
			}
			let nextData = await fetchNext()
			if let error = nextData?.error {
				handleNetworkError(error: error, fullScreen: showFullScreenLoader)
			} else if reset {
				data = nextData?.data ?? []
			} else {
				data.append(contentsOf: nextData?.data ?? [])
			}

			let uiTransactions = Array(Set(data))
			let grouped = Dictionary(grouping: uiTransactions, by: { $0.timestamp }).values.sorted(by: { $0.first!.timestamp! > $1.first!.timestamp! })
			transactions = grouped

			self.showFullScreenLoader = false
			self.pendingTask = nil
			completion?()
		}
	}

	/// Called `onAppear` of each transacition in list and if is last (bottom of list) asks for the next page
	/// - Parameter transaction: The appeared transaction
	func fetchNextPageIfNeeded(for transaction: NetworkDeviceRewardsSummary) {
		guard transaction == transactions.last?.last else {
			return
		}

		refresh(showFullScreenLoader: false, reset: false)
	}
	
	/// Called once the user tap the cell or the error button of a transaaction
	/// - Parameter transaction: The tapped transaction
	func handleTransactionTap(from transaction: NetworkDeviceRewardsSummary) {
		let itemId = device.id ?? ""
		Logger.shared.trackEvent(.userAction, parameters: [.actionName: .identifyProblems,
														   .contentType: .deviceRewardTransactions,
														   .itemId: .custom(itemId)])

//		guard let datum = transaction.datum else {
//			return
//		}
//
//		let errorButtonTitle: String = errorIndicationButtonTitle
//		let rewardsCardOverview = DeviceRewardsOverview(datum: datum).toRewardsCardOverview(title: "", errorButtonTitle: errorButtonTitle)
//		let viewModel = ViewModelsFactory.getRewardDetailsViewModel(device: device, followState: followState, overview: rewardsCardOverview)
//		Router.shared.navigateTo(.rewardDetails(viewModel))
	}
}

extension TransactionDetailsViewModel: HashableViewModel {
    func hash(into hasher: inout Hasher) {
        hasher.combine(device.id)
    }
}

private extension TransactionDetailsViewModel {

	@discardableResult
	/// Fetches the next page
	/// - Returns: Tuple with received data and error, if exists
	private func fetchNext() async -> (data: [NetworkDeviceRewardsSummary]?, error: NetworkErrorResponse?)? {
		// if there is a pending request of there is no next page, we stop
		guard let nextPagination = pagination.getNextPagination() else {
			return nil
		}

		let page = nextPagination.page
		let fromDate = nextPagination.fromDate
		let toDate = nextPagination.toDate

		do {
			let result = try await self.tokenUseCase.getTransactions(deviceId: device.id ?? "",
																	 page: page,
																	 fromDate: fromDate,
																	 toDate: toDate)
			switch result {
				case .success(let transactionsObj):
					// Once the request is successful, we update the pagination with the latest state
					pagination = .init(device: device,
									   transactionsObject: transactionsObj,
									   currentPage: page,
									   fromDate: fromDate,
									   toDate: toDate)
					return (transactionsObj?.data ?? [], nil)
				case .failure(let error):
					return (nil, error)
			}
		} catch {
			print(error)
		}

		return nil
	}
	
	/// Handles the received error and shows it on UI
	/// - Parameters:
	///   - error: The received network error
	///   - fullScreen: If true we show the full screen UI, if not we show an error toast
	func handleNetworkError(error: NetworkErrorResponse, fullScreen: Bool) {
		let info = error.uiInfo
		guard fullScreen else {
			if let message = info.description?.attributedMarkdown {
				Toast.shared.show(text: message)
			}

			return
		}

		let obj = info.defaultFailObject(type: .noTransactions) { [weak self] in
			self?.isFailed = false
			self?.refresh(showFullScreenLoader: true, reset: true)
		}

		self.failObj = obj
		self.isFailed = true
	}
}
