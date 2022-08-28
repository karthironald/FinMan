//
//  FMTransactionRowViewModel.swift
//  FinMan
//
//  Created by Karthick Selvaraj on 26/04/21.
//

import Foundation
import Combine

class FMTransactionRowViewModel: ObservableObject, Dated {
    var createdDate: Date {
        Date()
    }
    @Published var transaction: FMDTransaction
    
    private let transactionRepository = FMTransactionRepository.shared
    var id: Int?
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Init Methods
    init(transaction: FMDTransaction) {
        self.transaction = transaction
        
        $transaction
            .compactMap { $0.id }
            .assign(to: \.id, on: self)
            .store(in: &cancellables)
    }
    
    // MARK: - Custom methods
    
    func update(transaction: FMDTransaction, resultBlock: @escaping (Error?) -> Void) {
//        transactionRepository.update(transaction: transaction, oldTransaction: self.transaction, resultBlock: resultBlock)
        self.transaction = transaction
    }
    
    func delete(resultBlock: @escaping (Error?) -> Void) {
//        transactionRepository.delete(transaction: transaction, resultBlock: resultBlock)
    }
    
    func imageName() -> String {
        if let date = transaction.transactionAt {
            let day = Calendar.current.component(.day, from: date)
            return day.description
        }
        return "0"
    }
    
    func transactionAt() -> String {
        transaction.transactionAt?.toString() ?? "--"
    }
}

extension FMTransactionRowViewModel: Equatable {
    
    static func == (lhs: FMTransactionRowViewModel, rhs: FMTransactionRowViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
}
