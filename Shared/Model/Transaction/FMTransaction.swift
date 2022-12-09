//
//  FMTransaction.swift
//  FinMan (iOS)
//
//  Created by Karthick Selvaraj on 09/04/21.
//
import Foundation
import FirebaseFirestoreSwift
import FirebaseFirestore

// MARK: - FMAddTransactionRequest
struct FMAddTransactionRequest: Codable {
    let name: String?
    let value: Double?
    let transactionType: String?
    let accountID, expenseCategoryID, eventID, incomeSourceID: Int?
    let transactionAt, comments: String?

    enum CodingKeys: String, CodingKey {
        case name, value
        case transactionType = "transaction_type"
        case accountID = "account_id"
        case expenseCategoryID = "expense_category_id"
        case eventID = "event_id"
        case incomeSourceID = "income_source_id"
        case transactionAt = "transaction_at"
        case comments
    }
}

// MARK: - FMTransactionResponse
struct FMDTransactionResponse: Codable {
    let count: Int?
    let next: String?
    let previous: String?
    let results: [FMDTransaction]?
}

// MARK: - FMSummary
struct FMSummary: Codable {
    let totalExpense, totalIncome: Double?
    let incomes: [Income]?
    let expenses: [Expense]?

    enum CodingKeys: String, CodingKey {
        case totalExpense = "total_expense"
        case totalIncome = "total_income"
        case incomes, expenses
    }
}

extension FMSummary {
    struct Expense: Codable {
        let category: String?
        let value: Double?
    }

    struct Income: Codable {
        let source: String?
        let value: Double?
    }
}


// MARK: - Result
struct FMDTransaction: Codable {
    let id: Int?
    let incomeSource: FMDIncomeSource?
    let expenseCategory: FMDExpenseCategory?
    let event: FMEvent?
    let account: FMAccount?
    let createdAt, updatedAt: Date
    let name: String?
    let value: Double?
    let transactionAt: Date
    let transactionType: String?
    let comments: String?

    enum CodingKeys: String, CodingKey {
        case id
        case incomeSource = "income_source"
        case expenseCategory = "expense_category"
        case event, account
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case name, value
        case transactionAt = "transaction_at"
        case transactionType = "transaction_type"
        case comments
    }
}

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
            case .quatarly: return "Quarterly"
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
    }
    
    enum TransactionType: String, CaseIterable {
        case income, expense
    }
    
    enum ExpenseCategory: String, CaseIterable {
        case housing, transportation, food, utilities, clothing, medical, insurance, household, personal, debt, education, savings, gifts, entertainment, investment, others
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

extension FMDTransaction {
    
    static var sampleData = [
        FMDTransaction(id: 1, incomeSource: FMDIncomeSource(id: 1, createdAt: Date(), updatedAt: Date(), name: "IC", frequency: "onetime"), expenseCategory: FMDExpenseCategory(id: 1, createdAt: Date(), updatedAt: Date(), name: "EC 1", monthlyBudget: 10, yearlyBudget: 120), event: nil, account: FMAccount.sampleData.first!, createdAt: Date(), updatedAt: Date(), name: "New Transaction", value: 100, transactionAt: Date(), transactionType: "income", comments: "Sample")
    ]
    
}

extension FMTransaction {

    enum Keys: String {
        case id, value, frequency, source, comments, userId, accountId, transactionType, expenseCategory, transactionDate, createdAt
    }
    
}
