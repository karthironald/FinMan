//
//  FMIncomeListViewModel.swift
//  FinMan
//
//  Created by Karthick Selvaraj on 10/04/21.
//

import Foundation
import Combine

class FMIncomeListViewModel: ObservableObject {
    
    @Published var incomeRepository = FMIncomeRepository.shared
    @Published var incomeRowViewModel: [FMIncomeRowViewModel] = []
    @Published var groupedIncomeRowViewModel: [String: [FMIncomeRowViewModel]] = [:]
    @Published var isFetching: Bool = true
    
    private var cancellables: Set<AnyCancellable> = []
    
    
    init() {
        incomeRepository.$incomes
            .map { income in
                income.map(FMIncomeRowViewModel.init)
            }
            .assign(to: \.incomeRowViewModel, on: self)
            .store(in: &cancellables)
        
        incomeRepository.$isFetching
            .map {
                print("🔵 Current fetching status: \($0)")
                return $0
            }
            .assign(to: \.isFetching, on: self)
            .store(in: &cancellables)
        $incomeRowViewModel
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                if let groupdIncome = self?.incomeRowViewModel.groupedBy(dateComponents: [.month, .year]) {
                    self?.groupedIncomeRowViewModel = groupdIncome
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Custom methods
    
    func addNew(income: FMIncome) {
        incomeRepository.add(income)
    }
    
    func totalIncome() -> Double {
        incomeRepository.incomes.map{ $0.value }.reduce(0.0, +)
    }
    
}
