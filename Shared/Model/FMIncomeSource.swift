//
//  FMIncomeSource.swift
//  FinMan (iOS)
//
//  Created by Karthick Selvaraj on 24/08/22.
//

import Foundation

struct FMIncomeSourceResponse: Codable {
    let count: Int?
    let next, previous: String?
    let results: [FMDIncomeSource]?
}

// MARK: - IncomeSource
struct FMDIncomeSource: Codable, Identifiable, Hashable {
    let id: Int?
    let createdAt, updatedAt: Date?
    let name, frequency: String?

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case name, frequency
    }
}

extension FMDIncomeSource {
    static var `default` = FMDIncomeSource(id: nil, createdAt: nil, updatedAt: nil, name: "None", frequency: "onetime")
}
