//
//  FMExpenseCategory.swift
//  FinMan (iOS)
//
//  Created by Karthick Selvaraj on 28/08/22.
//

import Foundation


struct FMExpenseCategoryResponse: Codable {
    let count: Int?
    let next, previous: String?
    let results: [FMDExpenseCategory]?
}

// MARK: - ExpenseCategory
struct FMDExpenseCategory: Codable, Identifiable, Hashable {
    let id: Int?
    let createdAt, updatedAt: Date?
    let name: String?
    let monthlyBudget, yearlyBudget: Double?

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case name
        case monthlyBudget = "monthly_budget"
        case yearlyBudget = "yearly_budget"
    }
}

extension FMDExpenseCategory {
    static var `default` = FMDExpenseCategory(id: nil, createdAt: nil, updatedAt: nil, name: "None", monthlyBudget: 10, yearlyBudget: 120)
}