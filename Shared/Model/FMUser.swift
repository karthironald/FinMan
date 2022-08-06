//
//  FMUser.swift
//  FinMan (iOS)
//
//  Created by Karthick Selvaraj on 31/07/22.
//

import Foundation


// MARK: - Welcome
struct FMUser: Codable {
    let id: Int
    let username, firstName, lastName, email: String

    enum CodingKeys: String, CodingKey {
        case id, username
        case firstName = "first_name"
        case lastName = "last_name"
        case email
    }
}

struct Token: Codable {
    let refresh, access: String
}

