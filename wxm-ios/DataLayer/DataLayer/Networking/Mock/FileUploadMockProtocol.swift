//
//  FileUploadMockProtocol.swift
//  DataLayer
//
//  Created by Pantelis Giazitsis on 6/2/25.
//

import Foundation

class FileUploadMockProtocol: URLProtocol, @unchecked Sendable {
	nonisolated(unsafe) static weak var sessionDelegate: URLSessionTaskDelegate?

	private var progressTimer: Timer?
	private var sentBytes: Int64 = 0
	private let expectedBytesToSend: Int64 = 1000000  // 1MB

	override init(request: URLRequest, cachedResponse: CachedURLResponse?, client: URLProtocolClient?) {
		super.init(request: request, cachedResponse: cachedResponse, client: client)
	}

	override class func canInit(with request: URLRequest) -> Bool {
		return true
	}

	override class func canonicalRequest(for request: URLRequest) -> URLRequest {
		request
	}

	override func startLoading() {
		if task?.originalRequest?.url?.absoluteString == Self.failUrl {
			self.client?.urlProtocol(self, didFailWithError: NSError(domain: "\(Self.self)", code: -1))
			self.client?.urlProtocolDidFinishLoading(self)
		} else {
			startUploadProgress()
		}
	}

	override func stopLoading() {
		progressTimer?.invalidate()
		sentBytes = 0
	}
}

extension FileUploadMockProtocol {
	static let successUrl = "https://dummy.com"
	static let failUrl = "https://dummy_fail.com"
}

private extension FileUploadMockProtocol {
	func startUploadProgress() {
		let steps: [Int64] = [expectedBytesToSend/3,
							  expectedBytesToSend/2,
							  expectedBytesToSend]

		progressTimer = Timer.scheduledTimer(withTimeInterval: 0.3,
											 repeats: true) { [weak self] timer  in
			guard let self else {
				return
			}
			let bytes = steps.first(where: { $0 > self.sentBytes })
			self.sentBytes = bytes ?? self.expectedBytesToSend

			self.notifyProgress()

			let finished = self.sentBytes == self.expectedBytesToSend
			if finished {
				timer.invalidate()
				self.finishUpload()
			}
		}
	}

	func notifyProgress() {
		FileUploadMockProtocol.sessionDelegate?.urlSession?(URLSession.shared,
															task: task!,
															didSendBodyData: self.sentBytes,
															totalBytesSent: self.sentBytes,
															totalBytesExpectedToSend: self.expectedBytesToSend)

	}

	func finishUpload() {
		guard let emptyResponseFile = Bundle(for: type(of: self)).url(forResource: "empty_response",
																withExtension: "json"),
			  let data = try? Data(contentsOf: emptyResponseFile) else {
			return
		}

		client?.urlProtocol(self, didLoad: data)
		client?.urlProtocolDidFinishLoading(self)
	}
}
