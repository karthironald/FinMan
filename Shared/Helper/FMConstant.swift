//
//  FMConstant.swift
//  FinMan (iOS)
//
//  Created by Karthick Selvaraj on 15/05/21.
//

import Foundation
import SwiftUI

enum AppSettings {
    static let appPrimaryColour = Color.purple
    static let appSecondaryColour = Color.secondary.opacity(0.3)
    static let appCloseButtonColour = Color.secondary.opacity(0.5)
    static let appCornerRadius: CGFloat = 10
    static let appShadowColour = Color.secondary.opacity(0.7)
    static let vStackSpacing: CGFloat = 15
}

let kCommonErrorMessage = "Something went wrong"
let kOkay = "Okay"
let kTimePeriodAllOptionValue = 999

enum FMTimePeriod: String, CaseIterable {
    case today
    case yesterday
    case thisWeek
    case lastWeek
    case thisMonth
    case lastMonth
    case thisYear
    case lastYear
    case last7Days
    case last30Days
    case last60Days
    case last90Days
    case all
    
    func title() -> String {
        switch self {
        case .today: return "Today"
        case .yesterday: return "Yesterday"
        case .thisWeek: return "This Week"
        case .lastWeek: return "Last Week"
        case .thisMonth: return "This Month"
        case .lastMonth: return "Last Month"
        case .thisYear: return "This Year"
        case .lastYear: return "Last Year"
        case .last7Days: return "Last 7D"
        case .last30Days: return "Last 30D"
        case .last60Days: return "Last 60D"
        case .last90Days: return "Last 90D"
        case .all: return "All Time"
        }
    }
}
