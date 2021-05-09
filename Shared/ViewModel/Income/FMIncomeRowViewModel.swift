//
//  FMIncomeRowViewModel.swift
//  FinMan
//
//  Created by Karthick Selvaraj on 26/04/21.
//

import Foundation
import Combine

class FMIncomeRowViewModel: ObservableObject, Dated {
    
    @Published var income: FMIncome
    
    private let incomeRepository = FMIncomeRepository.shared
    var id: String?
    private var cancellables: Set<AnyCancellable> = []
    var createdDate: Date {
        income.createdAt?.dateValue() ?? Date()
    }
    
    init(income: FMIncome) {
        self.income = income
        
        $income
            .compactMap { $0.id }
            .assign(to: \.id, on: self)
            .store(in: &cancellables)
    }
    
    func update(income: FMIncome) {
        incomeRepository.update(income: income, oldIncome: self.income)
        self.income = income
    }
    
    func delete() {
        incomeRepository.delete(income: income)
    }
    
    func imageName() -> String {
        let date = income.createdAt?.dateValue() ?? Date()
        let components = Calendar.current.dateComponents([.day], from: date)
        return String(components.day ?? 0)
    }
    
}

extension FMIncomeRowViewModel: Equatable {
    
    static func == (lhs: FMIncomeRowViewModel, rhs: FMIncomeRowViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
}
