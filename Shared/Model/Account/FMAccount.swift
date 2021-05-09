//
//  FMAccount.swift
//  FinMan
//
//  Created by Karthick Selvaraj on 02/05/21.
//

import Foundation
import FirebaseFirestoreSwift
import FirebaseFirestore

struct FMAccount: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var comments: String? = nil
    var userId: String?
    var income: Double = 0.0
    var expense: Double = 0.0
    var incomeCount: Int64 = 0
    var expenseCount: Int64 = 0
    @ServerTimestamp var createdAt: Timestamp?
}

extension FMAccount {
    
    static var sampleData = [
        FMAccount(id: UUID().uuidString, name: "Profession", comments: "iOS developer", income: 100000, expense: 50000),
        FMAccount(id: UUID().uuidString, name: "Chick Farm", comments: "Chick farm", income: 20000, expense: 5000),
        FMAccount(id: UUID().uuidString, name: "Cattle Farm", comments: "Cattle farm", income: 500, expense: 100)
    ]
    
}
