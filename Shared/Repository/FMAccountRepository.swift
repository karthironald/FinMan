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
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                self.accounts = querySnapshot?.documents.compactMap({ document in
                    try? document.data(as: FMAccount.self)
                }) ?? []
                if selectedAccount == nil {
                    self.selectedAccount = self.accounts.first
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
    
}
