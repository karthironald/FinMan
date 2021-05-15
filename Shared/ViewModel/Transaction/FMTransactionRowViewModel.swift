//
//  FMTransactionRowViewModel.swift
//  FinMan
//
//  Created by Karthick Selvaraj on 26/04/21.
//

import Foundation
import Combine

class FMTransactionRowViewModel: ObservableObject, Dated {
    
    @Published var transaction: FMTransaction
    
    private let transactionRepository = FMTransactionRepository.shared
    var id: String?
    private var cancellables: Set<AnyCancellable> = []
    var createdDate: Date {
        transaction.transactionDate?.dateValue() ?? Date()
    }
    
    init(transaction: FMTransaction) {
        self.transaction = transaction
        
        $transaction
            .compactMap { $0.id }
            .assign(to: \.id, on: self)
            .store(in: &cancellables)
    }
    
    func update(transaction: FMTransaction) {
        transactionRepository.update(transaction: transaction, oldTransaction: self.transaction)
        self.transaction = transaction
    }
    
    func delete() {
        transactionRepository.delete(transaction: transaction)
    }
    
    func imageName() -> String {
        let date = transaction.transactionDate?.dateValue() ?? Date()
        let components = Calendar.current.dateComponents([.day], from: date)
        return String(components.day ?? 0)
    }
    
}

extension FMTransactionRowViewModel: Equatable {
    
    static func == (lhs: FMTransactionRowViewModel, rhs: FMTransactionRowViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
}
