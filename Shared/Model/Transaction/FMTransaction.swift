//
//  FMTransaction.swift
//  FinMan (iOS)
//
//  Created by Karthick Selvaraj on 09/04/21.
//
import Foundation
import FirebaseFirestoreSwift
import FirebaseFirestore
import SwiftUI

struct FMTransaction: Identifiable, Codable {
    @DocumentID var id: String?
    var value: Double
    var frequency: String? = nil
    var source: String? = nil
    var comments: String? = nil
    var userId: String?
    var accountId: String?
    var transactionType: String = TransactionType.income.rawValue
    var expenseCategory: String? = nil
    @ServerTimestamp var transactionDate: Timestamp?
    @ServerTimestamp var createdAt: Timestamp?
}

extension FMTransaction {
    
    enum IncomeFrequency: String, CaseIterable {
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
    
    enum IncomeSource: String, CaseIterable {
        case earned, profit, interest, dividend, rental, capitalGain, royalty
        
        var title: String {
            switch self {
            case .earned: return "Earned"
            case .profit: return "Profit"
            case .interest: return "Interest"
            case .dividend: return "Dividend"
            case .rental: return "Rental"
            case .capitalGain: return "Capital Gains"
            case .royalty: return "Royalty"
            }
        }
        
        var info: String {
            switch self {
            case .earned: return "Money that you earn by doing something or by spending your time"
            case .profit: return "Money that you earn by selling something for more than it costs you to make"
            case .interest: return "Money you get as a result of lending your money to someone else to use"
            case .dividend: return "Money that you get as a return on shares of a company you own"
            case .rental: return "Money that you get as a result of renting out an asset that you have, like a house, or a building"
            case .capitalGain: return "Money that you get as a result of increase in value of an asset that you own"
            case .royalty: return "Money you get as a result of letting someone use your products, ideas, or processes."
            }
        }
        
        var imageName: String {
            switch self {
            case .earned: return "briefcase"
            case .profit: return "arrow.triangle.pull"
            case .interest: return "square.grid.3x3.topleft.fill"
            case .dividend: return "building.columns"
            case .rental: return "building.2.crop.circle"
            case .capitalGain: return "arrow.triangle.branch"
            case .royalty: return "books.vertical"
            }
        }
        var colour: Color {
            switch self {
            case .earned: return .blue
            case .profit: return .green
            case .interest: return .orange
            case .dividend: return .pink
            case .rental: return .purple
            case .capitalGain: return .red
            case .royalty: return .yellow
            }
        }
    }
    
    enum TransactionType: String, CaseIterable {
        case income, expense
    }
    
    enum ExpenseCategory: String, CaseIterable {
        case housing, transportation, food, utilities, clothing, medical, insurance, household, personal, debt, education, savings, gifts, entertainment, investment, others
        
        var colour: Color {
            switch self {
            case .housing: return .blue
            case .transportation: return Color(.systemGray6)
            case .food: return Color(.systemGray3)
            case .utilities: return .pink
            case .clothing: return .purple
            case .medical: return Color(.magenta)
            case .insurance: return .yellow
            case .household: return Color(.brown)
            case .personal: return Color(.cyan)
            case .debt: return .red
            case .education: return Color(.systemGray2)
            case .savings: return .orange
            case .gifts: return Color(.systemGray4)
            case .entertainment: return Color(.systemGray5)
            case .investment: return .green
            case .others: return Color(.systemIndigo)
            }
        }
    }
    
}

extension FMTransaction {
    
    static var sampleData = [
        FMTransaction(id: UUID().uuidString, value: 1000, frequency: IncomeFrequency.onetime.rawValue, source: IncomeSource.earned.rawValue, comments: nil, userId: nil),
        FMTransaction(id: UUID().uuidString, value: 1000, frequency: IncomeFrequency.weekly.rawValue, source: IncomeSource.dividend.rawValue, comments: nil, userId: nil),
        FMTransaction(id: UUID().uuidString, value: 1000, frequency: IncomeFrequency.monthly.rawValue, source: IncomeSource.capitalGain.rawValue, comments: nil, userId: nil),
        FMTransaction(id: UUID().uuidString, value: 1000, frequency: IncomeFrequency.yearly.rawValue, source: IncomeSource.interest.rawValue, comments: nil, userId: nil),
    ]
    
}

extension FMTransaction {

    enum Keys: String {
        case id, value, frequency, source, comments, userId, accountId, transactionType, expenseCategory, transactionDate, createdAt
    }
    
}
