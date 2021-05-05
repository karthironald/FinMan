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
    private let incomeRepository = FMIncomeRepository.shared
    var id: String?
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(account: FMAccount) {
        self.account = account
        
        $account
            .compactMap { $0.id }
            .assign(to: \.id, on: self)
            .store(in: &cancellables)
    }
    
    func update(account: FMAccount) {
        self.account = account
        accountRepository.update(account: account)
    }
    
    func delete() {
        accountRepository.delete(account: account)
    }
    
}

