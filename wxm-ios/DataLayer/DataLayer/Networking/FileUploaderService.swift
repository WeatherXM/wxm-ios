//
//  FileUploaderService.swift
//  DataLayer
//
//  Created by Pantelis Giazitsis on 3/1/25.
//

import Foundation
import Alamofire

public final class FileUploaderService: Sendable {

	private let backgroundSession: URLSession!
	private let sessionDelegate: SessionDelegate = SessionDelegate()

	public init() {
		let bundleIdentifier = Bundle.main.bundleIdentifier ?? UUID().uuidString
		let sessionId = "\(bundleIdentifier).background"

		let config = URLSessionConfiguration.background(withIdentifier: sessionId)
		config.shouldUseExtendedBackgroundIdleMode = true
		config.sessionSendsLaunchEvents = true // Ensures the app is launched or resumed in the background when a download or upload task completes.
		config.isDiscretionary = false // Disables discretionary behavior, meaning the system will not delay tasks based on power or network conditions.

		backgroundSession = URLSession(configuration: config, delegate: sessionDelegate, delegateQueue: nil)
	}

	func uploadFile(file: URL, to url: URL) throws {
		guard let data = FileManager.default.contents(atPath: file.path) else {
			return
		}

		try uploadData(data, to: url)
	}
}

private extension FileUploaderService {
	func uploadData(_ data: Data, to url: URL) throws {
		let boundary = UUID().uuidString
		var request = URLRequest(url: url)
		request.httpMethod = HTTPMethod.post.rawValue

		request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
		let body = generateRequestBody(fileData: data, boundary: boundary)
		request.setValue(String(body.count), forHTTPHeaderField: "Content-Length")
		let bodyFileURL = try saveBodyToTemp(body)
		let task = backgroundSession.uploadTask(with: request, fromFile: bodyFileURL)
		task.resume()
	}

	func generateRequestBody(fileData: Data, boundary: String) -> Data {
		var data = Data()
		let paramName = "file"

		data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
		data.append("Content-Disposition: form-data; name=\"\(paramName)\"; filename=\"\r\n\r\n".data(using: .utf8)!)
//		data.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
		data.append(fileData)
		data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

		return data
	}

	private func saveBodyToTemp(_ data: Data) throws -> URL {
		let tempDirectory = FileManager.default.temporaryDirectory
		let tempFileURL = tempDirectory.appendingPathComponent(UUID().uuidString)
		try data.write(to: tempFileURL)
		return tempFileURL
	}
}

private final class SessionDelegate: NSObject, URLSessionDelegate {

}
