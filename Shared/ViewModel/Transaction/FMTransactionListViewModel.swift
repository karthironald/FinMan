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
    
    func addNew(transaction: FMTransaction, resultBlock: @escaping (Error?) -> Void) {
        transactionRepository.add(transaction, resultBlock: resultBlock)
    }
    
    func fetchNextBadge() {
        transactionRepository.fetchNextPage()
    }
    
    func shouldEnableLoadMore() -> Bool {
        transactionRowViewModel.count < FMAccountRepository.shared.totalRecordsCount()
    }
    
    func fetchTransaction(for timePeriod: FMTimePeriod = .all) {
        if timePeriod == .all {
            transactionRepository.getTransactions()
        } else {
            let dates = FMHelper.startDate(type: timePeriod)
            if let sDate = dates.startDate, let eDate = dates.endDate {
                transactionRepository.filterTransaction(startDate: sDate, endDate: eDate)
            }
        }
    }

    func incomeTotal() -> Double {
        let incomeTrans = transactionRowViewModel.filter({ $0.transaction.transactionType.lowercased() == FMTransaction.TransactionType.income.rawValue.lowercased() })
        return incomeTrans.reduce(0) { result, rowViewModel in
            result + rowViewModel.transaction.value
        }
    }
    
    func expenseTotal() -> Double {
        let expenseTrans = transactionRowViewModel.filter({ $0.transaction.transactionType.lowercased() == FMTransaction.TransactionType.expense.rawValue.lowercased() })
        
        return expenseTrans.reduce(0) { result, rowViewModel in
            result + rowViewModel.transaction.value
        }
    }
    
}
