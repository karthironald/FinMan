//
//  FMIncome.swift
//  FinMan (iOS)
//
//  Created by Karthick Selvaraj on 09/04/21.
//
import Foundation

struct FMIncome: Identifiable {
    let id: UUID
    let value: Double
    let frequency: Frequency
    let comments: String? = nil
}

extension FMIncome {
    
    enum Frequency: String, CaseIterable {
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
        FMIncome(id: UUID(), value: 1000, frequency: .onetime),
        FMIncome(id: UUID(), value: 2000, frequency: .weekly),
        FMIncome(id: UUID(), value: 3000, frequency: .monthly),
        FMIncome(id: UUID(), value: 4000, frequency: .yearly),
    ]
    
}
