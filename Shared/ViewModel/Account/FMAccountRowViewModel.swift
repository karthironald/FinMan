//
//  FMAccountRowViewModel.swift
//  FinMan
//
//  Created by Karthick Selvaraj on 02/05/21.
//

import Foundation
import Combine

class FMAccountRowViewModel: ObservableObject {
    
    @Published var account: FMAccount
    
    private let accountRepository = FMAccountRepository.shared
    private let transactionRepository = FMTransactionRepository.shared
    var id: Int?
    
    private var cancellables: Set<AnyCancellable> = []
    
    //MARK: - Init methods
    
    init(account: FMAccount) {
        self.account = account
        
        $account
            .compactMap { $0.id }
            .assign(to: \.id, on: self)
            .store(in: &cancellables)
    }
    
    
    // MARK: - Custom methods
    
    func update(account: FMAccount, resultBlock: @escaping (Error?) -> Void) {
        self.account = account
        accountRepository.update(id: account.id, name: account.name, comments: account.accountDescription, resultBlock: resultBlock)
    }
    
    func delete(resultBlock: @escaping (Error?) -> Void) {
        accountRepository.delete(id: account.id, resultBlock: resultBlock)
    }
    
    func total() -> Double {
        Double((account.totalIncome ?? 0.0) - (account.totalExpense ?? 0.0))
    }
    
}

