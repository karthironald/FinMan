//
//  FMAccountListViewModel.swift
//  FinMan
//
//  Created by Karthick Selvaraj on 02/05/21.
//

import Foundation
import Combine

class FMAccountListViewModel: ObservableObject {
    
    @Published var accountRepository = FMAccountRepository.shared
    @Published var accountRowViewModel: [FMAccountRowViewModel] = []
    @Published var isFetching: Bool = true
    @Published var selectedAccountRowViewModel: FMAccountRowViewModel?
    
    var selectedAccount: FMAccount?
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Init Methods
    
    init() {
        accountRepository.$accounts.map { account in
            account.map(FMAccountRowViewModel.init)
        }
        .assign(to: \.accountRowViewModel, on: self)
        .store(in: &cancellables)
        
        accountRepository.$isFetching
            .map { $0 }
            .assign(to: \.isFetching, on: self)
            .store(in: &cancellables)
    }
    
    // MARK: - Custom methods
    
    func addNew(account: FMAccount, resultBlock: @escaping (Error?) -> Void) {
        accountRepository.add(account, resultBlock: resultBlock)
    }
    
}

