//
//  FMIncome.swift
//  FinMan (iOS)
//
//  Created by Karthick Selvaraj on 09/04/21.
//
import Foundation
import FirebaseFirestoreSwift
import FirebaseFirestore

struct FMIncome: Identifiable, Codable {
    @DocumentID var id: String?
    var value: Double
    var frequency: Int = 0
    var comments: String? = nil
    var userId: String?
    @ServerTimestamp var createdAt: Timestamp?
}

extension FMIncome {
    
    enum Frequency: Int, CaseIterable {
        case onetime, weekly, monthly, quatarly, halfEarly, yearly
        
        var title: String {
            switch self {
            case .onetime: return "One time"
            case .weekly: return "Weekly"
            case .monthly: return "Monthly"
            case .quatarly: return "Quatarly"
            case .halfEarly: return "Halfearly"
            case .yearly: return "Yearly"
            }
        }
    }
    
    
}

extension FMIncome {
    
    static var sampleData = [
        FMIncome(id: UUID().uuidString, value: 1000, frequency: 0, comments: nil, userId: nil),
        FMIncome(id: UUID().uuidString, value: 1000, frequency: 1, comments: nil, userId: nil),
        FMIncome(id: UUID().uuidString, value: 1000, frequency: 2, comments: nil, userId: nil),
        FMIncome(id: UUID().uuidString, value: 1000, frequency: 3, comments: nil, userId: nil),
    ]
    
}
