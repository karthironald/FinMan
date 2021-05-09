//
//  FMExtension.swift
//  FinMan
//
//  Created by Karthick Selvaraj on 02/05/21.
//

import Foundation

protocol Dated {
    var createdDate: Date { get }
}

extension Array where Element: Dated {
    func groupedBy(dateComponents: Set<Calendar.Component>) -> [String: [Element]] {
        let initial: [String: [Element]] = [:]
        let groupedByDateComponents = reduce(into: initial) { acc, cur in
            let components = Calendar.current.dateComponents(dateComponents, from: cur.createdDate)
            let date = Calendar.current.date(from: components)!
            
            let df = DateFormatter()
            df.dateFormat = "MMM yyyy"
            
            let dString = df.string(from: date)
            let existing = acc[dString] ?? []
            acc[dString] = existing + [cur]
        }
        
        return groupedByDateComponents
    }
    
}
