//
//  PhotosRepositoryImplTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 7/2/25.
//

import Testing
@testable import DataLayer
import DomainLayer
import UIKit

@Suite(.serialized)
struct PhotosRepositoryImplTests {
	private let repositoryImpl = PhotosRepositoryImpl(fileUploader: .init(),
													  locationManager: MockLocationManager())
	private let image: UIImage

	init() async throws {

		let path = Bundle(for: BundleAccessor.self).path(forResource: "dummy_image", ofType: "png")!
		let data = try Data(contentsOf: URL(fileURLWithPath: path))
		self.image = UIImage(data: data)!

		UserDefaultsService().remove(key: UserDefaults.GenericKey.arePhotoVerificationTermsAccepted.rawValue)
	}

	@Test() func savePhotoAndDelete() async throws {
		let path = try await savePhoto()
		try await repositoryImpl.deleteImage(path, deviceId: "124")
		#expect(!FileManager.default.fileExists(atPath: path))
    }

	@Test func savePhotoAndPurge() async throws {
		let path = try await savePhoto()
		try repositoryImpl.purgeImages()
		#expect(!FileManager.default.fileExists(atPath: path))
	}

	@Test func termsAccepted() async throws {
		#expect(repositoryImpl.areTermsAccepted == false)

		repositoryImpl.setTermsAccepted(false)
		#expect(repositoryImpl.areTermsAccepted == false)

		repositoryImpl.setTermsAccepted(true)
		#expect(repositoryImpl.areTermsAccepted == true)
	}
}

private extension PhotosRepositoryImplTests {
	func savePhoto() async throws -> String {
		let path = try await repositoryImpl.saveImage(image,
													  deviceId: "124",
													  metadata: nil)
		let filePath = try #require(path)
		return filePath
	}
}
