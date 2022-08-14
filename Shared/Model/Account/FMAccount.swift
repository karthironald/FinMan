//
//  FMAccount.swift
//  FinMan
//
//  Created by Karthick Selvaraj on 02/05/21.
//

import Foundation
import FirebaseFirestoreSwift
import FirebaseFirestore


// MARK: - FMAccountsResponse
struct FMAccountsResponse: Codable {
    let count: Int?
    let next, previous: String?
    let results: [FMAccount]?
}

struct FMAccount: Codable {
    let id: Int?
    let totalIncome, totalExpense: Double?
    var name, accountDescription: String?
    let createdAt, updatedAt: String?
    let isExceedBudget: Bool?
    let budget: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case totalIncome = "total_income"
        case totalExpense = "total_expense"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case name
        case accountDescription = "description"
        case isExceedBudget = "is_exceed_budget"
        case budget
    }
}

//struct FMAccount: Identifiable, Codable {
//    @DocumentID var id: String?
//    var name: String
//    var comments: String? = nil
//    var userId: String?
//    var income: Double = 0.0
//    var expense: Double = 0.0
//    var incomeCount: Int64 = 0
//    var expenseCount: Int64 = 0
//    @ServerTimestamp var createdAt: Timestamp?
//}
//
extension FMAccount {

    static var sampleData = [
        FMAccount(id: 1, totalIncome: 0, totalExpense: 0, name: "ABC", accountDescription: "Demo", createdAt: Date().toString(), updatedAt: Date().toString(), isExceedBudget: true, budget: 1000)
    ]

}

extension FMAccount {

    enum Keys: String {
        case id, name, comments, userId, income, expense, incomeCount, expenseCount, createdAt
    }

}
