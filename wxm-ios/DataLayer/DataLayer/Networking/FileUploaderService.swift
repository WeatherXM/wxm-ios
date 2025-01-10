
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
import DomainLayer
@preconcurrency import Combine

public final class FileUploaderService: Sendable {
	let totalProgressPublisher: AnyPublisher<(String, Double?), Never>
	let uploadErrorPublisher: AnyPublisher<(String, Error), Never>
	let uploadCompletedPublisher: AnyPublisher<(String, Int), Never>
	let uploadStartedPublisher: AnyPublisher<String, Never>
	private let totalProgressValueSubject: PassthroughSubject<(String, Double?), Never> = .init()
	private let uploadErrorPassthroughSubject: PassthroughSubject<(String, Error), Never> = .init()
	private let uploadCompletedPassthroughSubject: PassthroughSubject<(String, Int), Never> = .init()
	private let uploadStartedPassthroughSubject: PassthroughSubject<String, Never> = .init()
	private let backgroundSession: URLSession!
	private let sessionDelegate: SessionDelegate = SessionDelegate()
	nonisolated(unsafe) private var cancellables: Set<AnyCancellable> = Set()
	nonisolated(unsafe) private var taskFileBodyUrls: [URLSessionTask: URL] = [:]
	nonisolated(unsafe) private var taskFileUrls: [URLSessionTask: URL] = [:]
	nonisolated(unsafe) private var taskProgresses: [URLSessionTask: Double] = [:]

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
		uploadCompletedPublisher = uploadCompletedPassthroughSubject.eraseToAnyPublisher()
		uploadStartedPublisher = uploadStartedPassthroughSubject.eraseToAnyPublisher()

		sessionDelegate.taskCompletedCallback = { [weak self] task in
			guard let deviceId = task.taskDescription else {
				return
			}

			self?.removeFileBody(for: task)
			self?.removeFile(for: task)
			let totalFiles = self?.taskProgresses.keys.filter { $0.taskDescription == deviceId }.count ?? 0
			self?.purgeProgressesIfNeeded(for: deviceId)

			if let deviceId = task.taskDescription,
			   self?.getUploadState(for: deviceId) == nil {
				self?.uploadCompletedPassthroughSubject.send((deviceId, totalFiles))
			}
		}

		sessionDelegate.taskFailedCallback =  { [weak self] task, error in
			guard let deviceId = task.taskDescription else {
				return
			}

			if (error as NSError).code == NSURLErrorCancelled {
				self?.removeFile(for: task)
			}

			self?.removeFileBody(for: task)
			self?.purgeProgressesIfNeeded(for: deviceId)
			self?.uploadErrorPassthroughSubject.send((deviceId, error))
		}

		sessionDelegate.taskProgressCallback =  { [weak self] task, progress in
			guard let self,
				  let deviceId = task.taskDescription else {
				return
			}

			self.taskProgresses[task] = progress
			self.totalProgressValueSubject.send((deviceId, self.getTotalProgress(for: deviceId)))
		}

		backgroundSession.getAllTasks { tasks in
			tasks.forEach { print("\($0.taskIdentifier) - \($0.state)") }
			tasks.forEach { $0.cancel() }
			tasks.forEach { print("\($0.taskIdentifier) - \($0.state)") }

			print(tasks)
		}
	}

	func uploadFiles(files: [URL], to objects: [NetworkPostDevicePhotosResponse], for deviceId: String) throws {
		for (index, element) in files.enumerated() {
			if let uploadUrl = objects[index].url,
			   let url = URL(string: uploadUrl) {
				try uploadFile(file: element, to: url, for: deviceId)
			}
		}

		uploadStartedPassthroughSubject.send(deviceId)
	}

	func cancelUpload(for deviceId: String) {
		backgroundSession.getAllTasks { tasks in
			tasks.forEach { task in
				guard task.taskDescription == deviceId else {
					return
				}
				task.cancel()
			}
		}
	}

	func getUploadInProgressDeviceId() -> String? {
		taskFileUrls.keys.first?.taskDescription
	}

	func getUploadState(for deviceId: String) -> UploadState? {
		// If there is progress, we assume there are files in uploading state
		if let deviceProgress = getTotalProgress(for: deviceId) {
			return .uploading(deviceProgress)
		}

		// If there is no progress but there are still file url entries with existing files for this id,
		// we assume the process is failed
		let tasks = taskFileUrls.keys.filter { $0.taskDescription == deviceId }
		let files = tasks.compactMap { taskFileUrls[$0] }
		if files.first(where: { FileManager.default.fileExists(atPath: $0.path()) }) != nil {
			return .failed
		}

		return nil
	}
}

extension FileUploaderService {
	enum UploadState {
		case uploading(Double)
		case failed
	}
}

private extension FileUploaderService {
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

	func getTotalProgress(for deviceId: String) -> Double? {
		let tasks = taskProgresses.keys.filter { $0.taskDescription == deviceId }

		if tasks.isEmpty {
			return nil
		}

		let totalProgress = tasks.reduce(0) { $0 + (taskProgresses[$1] ?? 0.0) }
		return totalProgress / Double(tasks.count)
	}

	func purgeProgressesIfNeeded(for deviceId: String) {
		let tasks = taskProgresses.keys.filter { $0.taskDescription == deviceId }
		let isFinished = tasks.filter { $0.state == .running }.isEmpty
		guard isFinished else { return }
		tasks.forEach { taskProgresses.removeValue(forKey: $0) }
	}
}

private final class SessionDelegate: NSObject, @unchecked Sendable, URLSessionDataDelegate, URLSessionTaskDelegate, URLSessionDelegate {
	var taskCompletedCallback: GenericCallback<URLSessionTask>?
	var taskFailedCallback: ((URLSessionTask, Error) -> Void)?
	var taskProgressCallback: ((URLSessionTask, Double) -> Void)?

	override init() {
		super.init()
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
			self?.taskProgressCallback?(task, progress)
		}
	}
}

private extension Int {
	var isSuccessCode: Bool {
		200..<300 ~= self
	}
}
