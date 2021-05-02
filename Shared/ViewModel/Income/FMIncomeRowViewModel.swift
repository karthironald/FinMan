//
//  FMIncomeRowViewModel.swift
//  FinMan
//
//  Created by Karthick Selvaraj on 26/04/21.
//

import Foundation
import Combine

class FMIncomeRowViewModel: ObservableObject {
    
    @Published var income: FMIncome
    
    private let incomeRepository = FMIncomeRepository()
    var id: String?
    private var cancellables: Set<AnyCancellable> = []
    
    init(income: FMIncome) {
        self.income = income
        
        $income
            .compactMap { $0.id }
            .assign(to: \.id, on: self)
            .store(in: &cancellables)
    }
    
    func update(income: FMIncome) {
        self.income = income
        incomeRepository.update(income: income)
    }
    
    func delete() {
        incomeRepository.delete(income: income)
    }
    
    
}
