//
//  FMIncomeViewModel.swift
//  FinMan
//
//  Created by Karthick Selvaraj on 10/04/21.
//

import Foundation

class FMIncomeViewModel: ObservableObject {
    
    @Published var incomes: [FMIncome] = FMIncome.sampleData

    func addNew(income: FMIncome) {
        incomes.append(income)
    }
    
}
