//
//  FMHelper.swift
//  FinMan (iOS)
//
//  Created by Karthick Selvaraj on 15/05/21.
//

import Foundation
import AFDateHelper

class FMHelper {
    
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    static func percentage(of value: Double, in total: Double) -> Double {
        let percentage = (value * 100) / total
        return percentage
    }
    
    class func startDate(type: FMTimePeriod) -> (startDate: Date?, endDate: Date?) {
        let now = Date()
        
        switch type {
        case .today:
            return (now.dateFor(.startOfDay), now.dateFor(.endOfDay))
        case .yesterday:
            let yesterday = now.dateFor(.yesterday)
            return (yesterday.dateFor(.startOfDay), yesterday.dateFor(.endOfDay))
        case .thisWeek:
            return (now.dateFor(.startOfWeek), now.dateFor(.endOfWeek).dateFor(.endOfDay))
        case .lastWeek:
            let startOfThisWeek = now.dateFor(.startOfWeek)
            let aDayinlastWeek = startOfThisWeek.dateFor(.yesterday)
            return (aDayinlastWeek.dateFor(.startOfWeek), aDayinlastWeek.dateFor(.endOfWeek).dateFor(.endOfDay))
        case .thisMonth:
            return (now.dateFor(.startOfMonth), now.dateFor(.endOfMonth).dateFor(.endOfDay))
        case .lastMonth:
            let startOfThisMonth = now.dateFor(.startOfMonth)
            let aDayinLastMonth = startOfThisMonth.dateFor(.yesterday)
            return (aDayinLastMonth.dateFor(.startOfMonth), aDayinLastMonth.dateFor(.endOfMonth).dateFor(.endOfDay))
        case .thisYear:
            let year = now.component(.year)
            let day = 1
            let month = 1
            
            var customComponent = DateComponents()
            customComponent.year = year
            customComponent.month = month
            customComponent.day = day
            customComponent.hour = 12
            customComponent.minute = 0
            customComponent.second = 0
            
            let startOfYear = Calendar.current.date(from: customComponent)?.dateFor(.startOfDay)
            
            customComponent.year = (year ?? 0) + 1
            let endOfYear = Calendar.current.date(from: customComponent)?.dateFor(.yesterday).dateFor(.endOfDay)

            return (startOfYear, endOfYear)
        case .lastYear:
            let year = now.component(.year)!
            let day = 1
            let month = 1
            
            var customComponent = DateComponents()
            customComponent.year = year - 1
            customComponent.month = month
            customComponent.day = day
            customComponent.hour = 12
            customComponent.minute = 0
            customComponent.second = 0
            
            let startOfYear = Calendar.current.date(from: customComponent)?.dateFor(.startOfDay)
            
            customComponent.year = (customComponent.year ?? year) + 1
            let endOfYear = Calendar.current.date(from: customComponent)?.dateFor(.yesterday).dateFor(.endOfDay)

            return (startOfYear, endOfYear)
        case .last7Days:
            let startDate = dateForDays(ago: 7, from: now)
            let endDate = now.dateFor(.yesterday).dateFor(.endOfDay)
            
            return (startDate, endDate)
        case .last30Days:
            let startDate = dateForDays(ago: 30, from: now)
            let endDate = now.dateFor(.yesterday).dateFor(.endOfDay)
            
            return (startDate, endDate)
        case .last60Days:
            let startDate = dateForDays(ago: 60, from: now)
            let endDate = now.dateFor(.yesterday).dateFor(.endOfDay)
            
            return (startDate, endDate)
        case .last90Days:
            let startDate = dateForDays(ago: 90, from: now)
            let endDate = now.dateFor(.yesterday).dateFor(.endOfDay)
            
            return (startDate, endDate)
        default:
            return (nil, nil)
        }
    }
    
    static func dateForDays(ago: Int, from date: Date) -> Date {
        date.adjust(.day, offset: -ago).dateFor(.startOfDay)
    }
}
