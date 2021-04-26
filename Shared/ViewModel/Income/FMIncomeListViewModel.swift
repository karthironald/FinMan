//
//  FMIncomeListViewModel.swift
//  FinMan
//
//  Created by Karthick Selvaraj on 10/04/21.
//

import Foundation

class FMIncomeListViewModel: ObservableObject {
    
    var incomeRepository = FMIncomeRepository()
    
    // MARK: - Custom methods
    
    func addNew(income: FMIncome) {
        incomeRepository.add(income)
    }
    
    func totalIncome() -> Double {
        incomeRepository.incomes.map{ $0.value }.reduce(0.0, +)
    }
    
}
