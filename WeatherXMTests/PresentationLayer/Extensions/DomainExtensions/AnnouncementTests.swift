//
//  AnnouncementTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 29/4/25.
//

import Testing
@testable import WeatherXM
import DomainLayer

struct AnnouncementTests {

    @Test func toAnnouncementConfiguration() {
		let announcment = Announcement(id: nil,
									   title: "Title",
									   message: "Message",
									   actionLabel: "Action",
									   actionUrl: nil,
									   actionShow: true,
									   dismissable: false)
		let conf = announcment.toAnnouncementConfiguration(buttonAction: nil,
														   closeAction: {})
		#expect(conf.title == "Title")
		#expect(conf.description == "Message")
		#expect(conf.closeAction == nil)
    }
}
