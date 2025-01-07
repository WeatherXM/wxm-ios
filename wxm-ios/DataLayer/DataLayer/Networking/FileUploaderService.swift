//
//  FileUploaderService.swift
//  DataLayer
//
//  Created by Pantelis Giazitsis on 3/1/25.
//

import Foundation
import Alamofire
import MobileCoreServices
@preconcurrency import Combine

public final class FileUploaderService: Sendable {
	let totalProgressPublisher: AnyPublisher<Double?, Error>
	private let backgroundSession: URLSession!
	private let sessionDelegate: SessionDelegate = SessionDelegate()
	nonisolated(unsafe) private var cancellables: Set<AnyCancellable> = Set()

	public init() {
		let bundleIdentifier = Bundle.main.bundleIdentifier ?? UUID().uuidString
		let sessionId = "\(bundleIdentifier).background"

		let config = URLSessionConfiguration.background(withIdentifier: sessionId)
		config.shouldUseExtendedBackgroundIdleMode = true
		config.sessionSendsLaunchEvents = true // Ensures the app is launched or resumed in the background when a download or upload task completes.
		config.isDiscretionary = false // Disables discretionary behavior, meaning the system will not delay tasks based on power or network conditions.

		backgroundSession = URLSession(configuration: config, delegate: sessionDelegate, delegateQueue: nil)
		totalProgressPublisher = sessionDelegate.totalProgressPublisher
	}

	func uploadFile(file: URL, to url: URL, for deviceId: String) throws {
		guard let data = FileManager.default.contents(atPath: file.path) else {
			return
		}

		try uploadData(data, to: url, for: deviceId)
	}

	func getUploadInProgressDeviceId() -> String? {
		sessionDelegate.getInProgressTaskDescription()
	}
}

private extension FileUploaderService {
	func uploadData(_ data: Data, to url: URL, for deviceId: String) throws {
		let boundary = UUID().uuidString
		var request = URLRequest(url: url)
		request.httpMethod = HTTPMethod.post.rawValue

		request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
		let body = generateRequestBody(fileData: data, boundary: boundary)
		request.setValue(String(body.count), forHTTPHeaderField: "Content-Length")
		let bodyFileURL = try saveBodyToTemp(body)
		let task = backgroundSession.uploadTask(with: request, fromFile: bodyFileURL)
		task.taskDescription = deviceId
		task.resume()
	}

	func generateRequestBody(fileData: Data, boundary: String) -> Data {
		var data = Data()
		let paramName = "file"
		let fileName = "\(UUID().uuidString).jpg"
		let mimeType = "image/*"
		data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
		data.append("Content-Disposition: form-data; name=\"\(paramName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
		data.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
		data.append(fileData)
		data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

		return data
	}

	func saveBodyToTemp(_ data: Data) throws -> URL {
		let tempDirectory = FileManager.default.temporaryDirectory
		let tempFileURL = tempDirectory.appendingPathComponent(UUID().uuidString)
		try data.write(to: tempFileURL)
		return tempFileURL
	}

	func mimeType(for path: String) -> String {
		let pathExtension = URL(fileURLWithPath: path).pathExtension as NSString
		guard
			let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension, nil)?.takeRetainedValue(),
			let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue()
		else {
			return "application/octet-stream"
		}

		return mimetype as String
	}
}

private final class SessionDelegate: NSObject, @unchecked Sendable, URLSessionDataDelegate, URLSessionTaskDelegate, URLSessionDelegate {
	let totalProgressPublisher: AnyPublisher<Double?, Error>
	nonisolated(unsafe) private var progresses: [URLSessionTask: Double] = [:] {
		didSet {
			let count = self.progresses.count
			let sum = self.progresses.values.reduce(0, +)
			totalProgressValueSubject.send(sum/Double(count))
		}
	}
	private var totalProgressValueSubject: PassthroughSubject<Double?, Error> = .init()
	private let queue: DispatchQueue = DispatchQueue(label: "com.weatherxm.app.file_upload")

	override init() {
		totalProgressPublisher = totalProgressValueSubject.eraseToAnyPublisher()
		super.init()
	}

	func getInProgressTaskDescription() -> String? {
		progresses.keys.first?.taskDescription
	}

	func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
		print("\(error), \(task)")
		if let error {
			totalProgressValueSubject.send(completion: .failure(error))
		}
	}

	func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
		print(dataTask)
	}

	func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
		let progress = Double(totalBytesSent) / Double(totalBytesExpectedToSend) * 100.0
		print("Task \(task.taskIdentifier)-\(task.taskDescription): Upload progress: \(progress)%")
		print("TASK protgress \(task.progress)")
		DispatchQueue.main.async { [weak self] in
			self?.progresses[task] = progress
		}
	}
}
