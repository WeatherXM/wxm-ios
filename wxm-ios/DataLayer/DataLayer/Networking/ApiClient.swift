//
//  ApiClient.swift
//  DataLayer
//
//  Created by Hristos Condrea on 16/5/22.
//

import Alamofire
import Combine
import DomainLayer
import Foundation
import Toolkit

private enum Constants: String {
	case emptyJsonObject = "empty_json_object"
	case url = "url"
	case emptyObjectString = "{}"
}

public class ApiClient: Client {
	let session = {
		let conf = URLSessionConfiguration.default

#if MOCK
		/// In case of mock build we inject the MockProtocol to monitor the requests
		conf.protocolClasses?.insert(MockProtocol.self, at: 0)
#endif

		let session = Session(configuration: conf)
		return session
	}()

	nonisolated(unsafe) static let shared: ApiClient = ApiClient()

#warning("TODO: Improve publishers caching. For now, we perform everything in main thread to avoid race conditions")
	private let queue = DispatchQueue.main
	/// Cached publishers
	private var publishers: [URLRequest: Any] = [:]

	private lazy var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .custom { [weak self] decoder in
		let container = try decoder.singleValueContainer()
		let dateStr = try container.decode(String.self)
		let formatter = ISO8601DateFormatter()
		if let date = formatter.date(from: dateStr) {
			return date
		}

		formatter.formatOptions = [.withFullDate, .withFullTime, .withFractionalSeconds]
		if let date = formatter.date(from: dateStr) {
			return date
		}

		throw DecodingError.dataCorruptedError(in: container, debugDescription: "Could not serialize date")
	}

	private init() {}

	/// Performs the passed request
	/// - Parameters:
	///   - urlConvertible: The request to perform
	///   - mockFileName: For mock builds. Pass the json file you want to be returned
	/// - Returns: A publisher which contains the response
	func requestCodable<T: Codable>(_ urlConvertible: URLRequestConvertible, mockFileName: String? = nil) -> AnyPublisher<DataResponse<T, NetworkErrorResponse>, Never> {
		return performRequest(urlConvertible, mockFileName: mockFileName, additionalInterceptors: [])
	}

	/// Performs the passed request adding auth token
	/// - Parameters:
	///   - urlConvertible: The request to perform
	///   - mockFileName: For mock builds. Pass the json file you want to be returned
	/// - Returns: A publisher which contains the response
	func requestCodableAuthorized<T: Codable>(_ urlConvertible: URLRequestConvertible, mockFileName: String? = nil) -> AnyPublisher<DataResponse<T, NetworkErrorResponse>, Never> {
		let authInterceptor = AuthInterceptor()
		return performRequest(urlConvertible, mockFileName: mockFileName, additionalInterceptors: [authInterceptor])
	}

	/// Downloads the file for the passed request
	/// - Parameters:
	///   - urlConvertible: The request to perform
	///   - destinationFileUrl: The file url where the downloaded file will be saved
	/// - Returns: A publisher which contains the response
	func downloadFile(_ urlConvertible: URLRequestConvertible, destinationFileUrl: URL) -> AnyPublisher<DownloadResponse<Data, NetworkErrorResponse>, Never> {
		let interceptor = AuthInterceptor()
		let destination: DownloadRequest.Destination = { _, _ in
			(destinationFileUrl, [.removePreviousFile, .createIntermediateDirectories])
		}

		return session.download(urlConvertible, interceptor: interceptor, to: destination)
			.validate()
			.publishData()
			.map { [weak self] response in
				self?.debugPrintDownloadResponse(urlString: urlConvertible.urlRequest?.url?.absoluteString, fileUrl: response.fileURL)

				return response.mapError { error in
					guard let fileUrl = response.fileURL, let data = try? Data(contentsOf: fileUrl) else {
						return NetworkErrorResponse(initialError: error, backendError: nil)
					}

					let backendError = try? JSONDecoder().decode(BackendError.self, from: data)
					try? FileManager.default.removeItem(at: fileUrl)
					let networkError = NetworkErrorResponse(initialError: error, backendError: backendError)
					self?.logError(networkError)
					return networkError
				}
			}
			.eraseToAnyPublisher()
	}
}

private extension ApiClient {
    func performRequest<T: Codable>(_ urlConvertible: URLRequestConvertible,
                                                   mockFileName: String? = nil,
                                                   additionalInterceptors: [RequestInterceptor]) -> AnyPublisher<DataResponse<T, NetworkErrorResponse>, Never> {

        // Make sure the access of `publishers` dictionary is thread safe
        let publisher = Just(urlConvertible)
            .receive(on: queue)
            .flatMap { [weak self] urlConvertible in
                guard let self else {
                    // In case of self is nil, we return a dummy error. In general this case is imposible.
                    // This snippet is to avoid comppiler complains and force unwraps
                    let error = NetworkErrorResponse(initialError: AFError.explicitlyCancelled, backendError: nil)
                    let dummyResponse: DataResponse<T, NetworkErrorResponse> = DataResponse(request: nil,
                                                                                            response: nil,
                                                                                            data: nil,
                                                                                            metrics: nil,
                                                                                            serializationDuration: 0,
                                                                                            result: .failure(error))
                    return Just(dummyResponse).eraseToAnyPublisher()
                }

                // Return an already initialized publisher if exists
                if let publisher = self.publishers[urlConvertible.urlRequest!] as? AnyPublisher<DataResponse<T, NetworkErrorResponse>, Never> {
                    return publisher
                }

                self.insertMockResponse(for: urlConvertible, mockFileName: mockFileName)

                return self.performApiRequest(urlConvertible, additionalInterceptors: additionalInterceptors)
            }
            .handleEvents(receiveCompletion: { [weak self] _ in
                // Once the operation is completed, remove the publisher from the cache
                if let request = urlConvertible.urlRequest {
                    self?.publishers.removeValue(forKey: request)
                }
            }, receiveCancel: { [weak self] in
                if let request = urlConvertible.urlRequest {
                    self?.publishers.removeValue(forKey: request)
                }
            })
            .eraseToAnyPublisher()

        return publisher
    }

    /// Performs the request from the server, this funciton should not be called directy. Use `performRequest` to encapsulate the caching functionality
    /// - Parameters:
    ///   - urlConvertible: The request to perform
    ///   - additionalInterceptors: Interceptors to include
    /// - Returns: A publisher which contains the response
    func performApiRequest<T: Codable>(_ urlConvertible: URLRequestConvertible,
                                       additionalInterceptors: [RequestInterceptor]) -> AnyPublisher<DataResponse<T, NetworkErrorResponse>, Never> {
        let headersAdapter = RequestHeadersAdapter()
        let interceptor = Interceptor(adapters: [headersAdapter], interceptors: additionalInterceptors)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = dateDecodingStrategy
        let publisher = session.request(urlConvertible, interceptor: interceptor)
            .validate()
            .publishDecodable(type: T.self, decoder: decoder, emptyResponseCodes: [200, 201, 204, 205])
            .map { [weak self] response in
                self?.debugResponse(urlString: urlConvertible.urlRequest?.url?.absoluteString, data: response.data)

                return response.mapError { error in
                    let backendError = response.data.flatMap { try? JSONDecoder().decode(BackendError.self, from: $0) }
                    let networkError = NetworkErrorResponse(initialError: error, backendError: backendError)
                    self?.logError(networkError)
                    return networkError
                }
            }
            .receive(on: DispatchQueue.main)
            .share()
            .eraseToAnyPublisher()

        // Insert publisher in dictionary
        if let request = urlConvertible.urlRequest {
            publishers[request] = publisher
        }

        return publisher
    }

    /// Adds an etry in `MockProtocol.responses` dictionary
    /// - Parameters:
    ///   - urlConvertible: The `urlConvertible` to get the url
    ///   - mockFileName: The mok file response
    func insertMockResponse(for urlConvertible: URLRequestConvertible, mockFileName: String?) {
        guard let url = urlConvertible.urlRequest?.url?.absoluteString,
              let mockFileName = mockFileName
        else {
            return
        }

        MockProtocol.responses[url] = mockFileName
    }

    func logError(_ error: NetworkErrorResponse) {
        Logger.shared.logNetworkError(error)
    }

    func debugPrintDownloadResponse(urlString: String?, fileUrl: URL?) {
        #if DEBUG || MOCK
            guard let fileUrl = fileUrl else {
                return
            }
            let data = try? Data(contentsOf: fileUrl)
            debugResponse(urlString: urlString, data: data)
        #endif
    }


	func debugResponse(urlString: String?, data: Data?) {
		DispatchQueue.global(qos: .background).async {
			print(urlString ?? "-")
			guard let data = data,
				  let json = try? JSONSerialization.jsonObject(with: data, options: []),
				  let prettyPrintedJsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
				  let noSlashesJsonData = try? JSONSerialization.data(withJSONObject: json, options: .withoutEscapingSlashes)
			else {
				print("Can not serialize JSON")
				print("data: \(String(data: data ?? Data(), encoding: .utf8) ?? "-")")
				return
			}

			if let jsonString = String(data: prettyPrintedJsonData, encoding: .utf8) {
				print(NSString(string: jsonString))
			} else {
				print("Failed to encode JSON string")
			}
			
			if let noSlashesString = String(data: noSlashesJsonData, encoding: .utf8),
			   noSlashesString.contains(Constants.emptyObjectString.rawValue) {
				let error = NSError(domain: Constants.emptyJsonObject.rawValue, code: -1, userInfo: [Constants.url.rawValue: urlString ?? ""])
				Logger.shared.logError(error)
			}
		}
    }
}
