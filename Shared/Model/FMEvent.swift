//
//  FMEvent.swift
//  FinMan (iOS)
//
//  Created by Karthick Selvaraj on 28/08/22.
//

import Foundation


struct FMEventsResponse: Codable {
    let count: Int?
    let next, previous: String?
    let results: [FMEvent]?
}

struct FMEvent: Codable, Identifiable, Hashable {
    let id: Int?
    let isExceedBudget: Bool?
    let totalIncome, totalExpense: Double?
    let createdAt, updatedAt: Date
    let name, fmEventDescription: String?
    let budget: Double?

    enum CodingKeys: String, CodingKey {
        case id
        case isExceedBudget = "is_exceed_budget"
        case totalIncome = "total_income"
        case totalExpense = "total_expense"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case name
        case fmEventDescription = "description"
        case budget
    }
}

extension FMEvent {
    static let `default` = FMEvent(id: nil, isExceedBudget: nil, totalIncome: nil, totalExpense: nil, createdAt: Date(), updatedAt: Date(), name: "None", fmEventDescription: nil, budget: nil)
}
