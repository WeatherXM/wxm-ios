//
//  EmailPasswordCodable.swift
//  DataLayer
//
//  Created by Hristos Condrea on 8/8/22.
//

import Foundation

struct EmailPasswordCodable: Codable {
    let email: String
    let password: String

    init(email: String, password: String) {
        self.email = email
        self.password = password
    }
}
