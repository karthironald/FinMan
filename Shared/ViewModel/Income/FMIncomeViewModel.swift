//
//  FMIncomeViewModel.swift
//  FinMan
//
//  Created by Karthick Selvaraj on 10/04/21.
//

import Foundation

class FMIncomeViewModel: ObservableObject {
    
    @Published var incomes: [FMIncome] = FMIncome.sampleData

    
    // MARK: - Custom methods
    
    func addNew(income: FMIncome) {
        incomes.append(income)
    }
    
    func totalIncome() -> Double {
        incomes.map{ $0.value }.reduce(0.0, +)
    }
    
}
