//
//  MockProtocol.swift
//  DataLayer
//
//  Created by Pantelis Giazitsis on 26/1/23.
//

import Foundation

/// Should be implemented from API builders to provide file name for the mock response
protocol MockResponseBuilder {
    var mockFileName: String? { get }
}

/// Monitors the url requests and if provided a mock file we return the file data as response
class MockProtocol: URLProtocol {
    /// A static dictionary where we keep the moke file name for each mocked endpoint. Every entry is expected to be inserted from `ApiClient`
    /// The stucture is [`request url`: `file name`]
    /// eg ["https:/api-mock.weatherxm.com/api/v1/me/devices/123":  "get_user_device"]
    static var responses: [String: String] = [:]

    override init(request: URLRequest, cachedResponse: CachedURLResponse?, client: URLProtocolClient?) {
        super.init(request: request, cachedResponse: cachedResponse, client: client)
    }

    override class func canInit(with request: URLRequest) -> Bool {
        guard let absoluteString = request.url?.absoluteString else {
            return false
        }
        return responses[absoluteString] != nil
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let absoluteString = request.url?.absoluteString,
              let resource: String = Self.responses[absoluteString],
              let fileUrl = Bundle(for: type(of: self)).url(forResource: resource, withExtension: "json"),
              let data = try? Data(contentsOf: fileUrl)
        else {
            return
        }

		DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
			self?.client?.urlProtocol(self!, didLoad: data)
			self?.client?.urlProtocolDidFinishLoading(self!)
		}
    }

    override func stopLoading() {}
}
