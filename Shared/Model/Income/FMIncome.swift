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
    var frequency: String
    var source: String
    var comments: String? = nil
    var userId: String?
    @ServerTimestamp var createdAt: Timestamp?
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
    
    enum Source: String, CaseIterable {
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
    
}

extension FMIncome {
    
    static var sampleData = [
        FMIncome(id: UUID().uuidString, value: 1000, frequency: Frequency.onetime.rawValue, source: Source.earned.rawValue, comments: nil, userId: nil),
        FMIncome(id: UUID().uuidString, value: 1000, frequency: Frequency.weekly.rawValue, source: Source.dividend.rawValue, comments: nil, userId: nil),
        FMIncome(id: UUID().uuidString, value: 1000, frequency: Frequency.monthly.rawValue, source: Source.capitalGain.rawValue, comments: nil, userId: nil),
        FMIncome(id: UUID().uuidString, value: 1000, frequency: Frequency.yearly.rawValue, source: Source.interest.rawValue, comments: nil, userId: nil),
    ]
    
}
