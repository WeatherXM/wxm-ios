
//
//  FileUploaderService.swift
//  DataLayer
//
//  Created by Pantelis Giazitsis on 3/1/25.
//

import Foundation
import Alamofire
import MobileCoreServices
import Toolkit
@preconcurrency import Combine

public final class FileUploaderService: Sendable {
	let totalProgressPublisher: AnyPublisher<(String, Double?), Never>
	let uploadErrorPublisher: AnyPublisher<(String, Error), Never>
	private let totalProgressValueSubject: PassthroughSubject<(String, Double?), Never> = .init()
	private let uploadErrorPassthroughSubject: PassthroughSubject<(String, Error), Never> = .init()
	private let backgroundSession: URLSession!
	private let sessionDelegate: SessionDelegate = SessionDelegate()
	nonisolated(unsafe) private var cancellables: Set<AnyCancellable> = Set()
	nonisolated(unsafe) private var taskFileBodyUrls: [URLSessionTask: URL] = [:]
	nonisolated(unsafe) private var taskFileUrls: [URLSessionTask: URL] = [:]

	public init() {
		let bundleIdentifier = Bundle.main.bundleIdentifier ?? UUID().uuidString
		let sessionId = "\(bundleIdentifier).background"

		let config = URLSessionConfiguration.background(withIdentifier: sessionId)
		config.shouldUseExtendedBackgroundIdleMode = true
		config.sessionSendsLaunchEvents = true // Ensures the app is launched or resumed in the background when a download or upload task completes.
		config.isDiscretionary = false // Disables discretionary behavior, meaning the system will not delay tasks based on power or network conditions.

		backgroundSession = URLSession(configuration: config, delegate: sessionDelegate, delegateQueue: nil)
		backgroundSession.configuration.timeoutIntervalForRequest = 5
		backgroundSession.configuration.timeoutIntervalForResource = 10

		totalProgressPublisher = totalProgressValueSubject.eraseToAnyPublisher()
		uploadErrorPublisher = uploadErrorPassthroughSubject.eraseToAnyPublisher()

		sessionDelegate.taskCompletedCallback = { [weak self] task in
			self?.removeFileBody(for: task)
			self?.removeFile(for: task)
		}

		sessionDelegate.taskFailedCallback =  { [weak self] task, error in
			self?.removeFileBody(for: task)
			self?.uploadErrorPassthroughSubject.send((task.taskDescription ?? "", error))
		}

		sessionDelegate.taskProgressCallback =  { [weak self] task, progress in
			// Gather all tasks progess and send
			let total = self?.sessionDelegate.getTotalProgressForTaks(with: task.taskDescription)
			self?.totalProgressValueSubject.send((task.taskDescription ?? "", total))
		}

		backgroundSession.getAllTasks { tasks in
			tasks.forEach { print("\($0.taskIdentifier) - \($0.state)") }
			tasks.forEach { $0.cancel() }
			tasks.forEach { print("\($0.taskIdentifier) - \($0.state)") }

			print(tasks)
		}
	}

	func uploadFile(file: URL, to url: URL, for deviceId: String) throws {
		guard let data = FileManager.default.contents(atPath: file.path) else {
			return
		}

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
		taskFileBodyUrls[task] = bodyFileURL
		taskFileUrls[task] = file
	}

	func getUploadInProgressDeviceId(completion: @escaping GenericSendableCallback<String?>) {
		backgroundSession.getAllTasks { tasks in
			let validTaskDescription = tasks.first(where: { $0.taskDescription != nil })?.taskDescription
			completion(validTaskDescription)
		}
	}
}

private extension FileUploaderService {
	func generateRequestBody(fileData: Data, boundary: String) -> Data {
		var data = Data()
		let paramName = "file"
		let fileName = "\(UUID().uuidString).jpg"
		let mimeType = mimeType(for: fileName)
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

	func removeFileBody(for task: URLSessionTask) {
		guard let fileUrl = taskFileBodyUrls[task] else {
			return
		}
		try? FileManager.default.removeItem(at: fileUrl)
		taskFileBodyUrls.removeValue(forKey: task)
	}

	func removeFile(for task: URLSessionTask) {
		guard let fileUrl = taskFileUrls[task] else {
			return
		}
		try? FileManager.default.removeItem(at: fileUrl)
		taskFileUrls.removeValue(forKey: task)
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
	var taskCompletedCallback: GenericCallback<URLSessionTask>?
	var taskFailedCallback: ((URLSessionTask, Error) -> Void)?
	var taskProgressCallback: ((URLSessionTask, Double) -> Void)?

	nonisolated(unsafe) private var progresses: [URLSessionTask: Double] = [:]

	override init() {
		super.init()
	}

	func getTotalProgressForTaks(with description: String?) -> Double {
		let tasks = progresses.keys.filter { $0.taskDescription == description }
		let total = tasks.reduce(0.0) { $0 + (progresses[$1] ?? 0.0) }
		return total
	}

	func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
		print("completed \(error), \(task)")
		if let error {
			DispatchQueue.main.async { [weak self] in
				self?.taskFailedCallback?(task, error)
			}
		} else if let httpResponse = task.response as? HTTPURLResponse,
		   !httpResponse.statusCode.isSuccessCode {
			let error = NSError(domain: "", code: httpResponse.statusCode)
			DispatchQueue.main.async { [weak self] in
				self?.taskFailedCallback?(task, error)
			}
		} else if task.state == .completed {
			DispatchQueue.main.async { [weak self] in
				self?.taskCompletedCallback?(task)
			}
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
			self?.taskProgressCallback?(task, progress)
		}
	}
}

private extension Int {
	var isSuccessCode: Bool {
		200..<300 ~= self
	}
}
