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
}

extension FMIncome {
    
    enum Frequency: String {
        case onetime, weekly, monthly, quatarly, halfEarly, yearly
    }
    
}

extension FMIncome {
    
    static var sampleData = [
        FMIncome(id: UUID(), value: 150000, frequency: .onetime),
        FMIncome(id: UUID(), value: 1000, frequency: .weekly),
        FMIncome(id: UUID(), value: 40000, frequency: .monthly),
        FMIncome(id: UUID(), value: 700000, frequency: .yearly),
    ]
    
}
