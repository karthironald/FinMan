//
//  FMAccountRepository.swift
//  FinMan
//
//  Created by Karthick Selvaraj on 02/05/21.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

class FMAccountRepository: ObservableObject {
    
    static let shared = FMAccountRepository()
    private let path: String = "Account"
    private let store = Firestore.firestore()
    
    var userId = ""
    private let authenticationService = FMAuthenticationService.shared
    private var cancellables: Set<AnyCancellable> = []
    
    @Published var accounts: [FMAccount] = []
    @Published var selectedAccount: FMAccount?
    @Published var isFetching: Bool = false
    
    private init() {
        authenticationService.$user
            .compactMap { user in
                user?.uid
            }
            .assign(to: \.userId, on: self)
            .store(in: &cancellables)
        
        authenticationService.$user
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.getAccounts()
            }
            .store(in: &cancellables)
    }
    
    
    func add(_ account: FMAccount) {
        do {
            var newAccount = account
            newAccount.userId = userId
            _ = try store.collection(path).addDocument(from: newAccount)
        } catch {
            fatalError("Unable to add card: \(error.localizedDescription).")
        }
    }
    
    func getAccounts() {
        isFetching = true
        store.collection(path)
            .order(by: "createdAt", descending: true)
            .whereField("userId", isEqualTo: userId)
            .addSnapshotListener { [self] (querySnapshot, error) in
                
                let updatedAccounts = querySnapshot?.documentChanges ?? []

                if let error = error {
                    isFetching = false
                    print(error.localizedDescription)
                    return
                }
                
                let shouldSelectFirstAccount = (updatedAccounts.count == 1 && updatedAccounts.first!.type == .added)
                self.accounts = querySnapshot?.documents.compactMap({ document in
                    try? document.data(as: FMAccount.self)
                }) ?? []
                if selectedAccount == nil || shouldSelectFirstAccount {
                    self.selectedAccount = self.accounts.first
                } else {
                    if let account = self.accounts.filter({ $0.id == selectedAccount?.id }).first {
                        self.selectedAccount = account
                    }
                }
                isFetching = false
            }
    }
    
    func update(account: FMAccount) {
        guard let id = account.id else { return }
        do {
            try store.collection(path).document(id).setData(from: account)
        } catch {
            print("Unable to update card")
        }
    }
    
    func delete(account: FMAccount) {
        guard let id = account.id else { return }
        store.collection(path).document(id).delete(completion: { (error) in
            if let error = error {
                print(error.localizedDescription)
            }
        })
    }
    
    func totalRecordsCount() -> Int64 {
        (selectedAccount?.incomeCount ?? 0) + (selectedAccount?.expenseCount ?? 0)
    }
}
