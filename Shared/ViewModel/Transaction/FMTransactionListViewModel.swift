//
//  FMTransactionListViewModel.swift
//  FinMan
//
//  Created by Karthick Selvaraj on 10/04/21.
//

import Foundation
import Combine

class FMTransactionListViewModel: ObservableObject {
    
    @Published var transactionRepository = FMTransactionRepository.shared
    @Published var transactionRowViewModel: [FMTransactionRowViewModel] = []
    @Published var groupedTransactionRowViewModel: [String: [FMTransactionRowViewModel]] = [:]
    @Published var isFetching: Bool = true
    @Published var isPaginating: Bool = false
    
    private var cancellables: Set<AnyCancellable> = []
     

    init() {
        transactionRepository.$transactions
            .map { transaction in
                transaction.map(FMTransactionRowViewModel.init)
            }
            .assign(to: \.transactionRowViewModel, on: self)
            .store(in: &cancellables)
        
        transactionRepository.$isFetching
            .map {
                print("🔵 Current fetching status: \($0)")
                return $0
            }
            .assign(to: \.isFetching, on: self)
            .store(in: &cancellables)
        transactionRepository.$isPaginating
            .map { $0 }
            .assign(to: \.isPaginating, on: self)
            .store(in: &cancellables)
        $transactionRowViewModel
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                if let groupdTransaction = self?.transactionRowViewModel.groupedBy(dateComponents: [.month, .year]) {
                    self?.groupedTransactionRowViewModel = groupdTransaction
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Custom methods
    
    func addNew(transaction: FMTransaction) {
        transactionRepository.add(transaction)
    }
    
    func fetchNextBadge() {
        transactionRepository.fetchNextPage()
    }
    
}
