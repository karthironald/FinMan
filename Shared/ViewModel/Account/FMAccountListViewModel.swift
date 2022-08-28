//
//  FMAccountListViewModel.swift
//  FinMan
//
//  Created by Karthick Selvaraj on 02/05/21.
//

import Foundation
import Combine

class FMAccountListViewModel: ObservableObject {
    
    @Published var accountRepository = FMAccountRepository()
    @Published var accountRowViewModel: [FMAccountRowViewModel] = []
    @Published var isFetching: Bool = true
    @Published var selectedAccountRowViewModel: FMAccountRowViewModel?
    
    var selectedAccount: FMAccount?
    
    // MARK: - Init Methods

    
    // MARK: - Custom methods
    
    func addNew(name: String, comments: String?, resultBlock: @escaping (Error?) -> Void) {
        accountRepository.add(name: name, comments: comments, resultBlock: resultBlock)
    }
    
}

