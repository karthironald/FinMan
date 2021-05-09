//
//  FMTransactionRepository.swift
//  FinMan
//
//  Created by Karthick Selvaraj on 26/04/21.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

let kPaginationCount = 20

class FMTransactionRepository: ObservableObject {
    
    static let shared = FMTransactionRepository()
    private let path: String = "Transaction"
    private let store = Firestore.firestore()
    
    var userId = ""
    var accountId = ""
    private let authenticationService = FMAuthenticationService.shared
    private let accountRepository = FMAccountRepository.shared
    private var cancellables: Set<AnyCancellable> = []
    
    @Published var transactions: [FMTransaction] = []
    @Published var isFetching: Bool = false
    @Published var isPaginating: Bool = false
    
    var lastDocument: DocumentSnapshot?
    var transactionQuery: Query?
    
    private init() {
        authenticationService.$user
            .compactMap { user in
                user?.uid
            }
            .assign(to: \.userId, on: self)
            .store(in: &cancellables)
        
        authenticationService.$user
            .debounce(for: 0.85, scheduler: RunLoop.main) // Delay the network request
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.getTransactions()
            }
            .store(in: &cancellables)
        accountRepository.$selectedAccount
            .compactMap {
                print("🟢 \(String(describing: $0?.name)): \(String(describing: $0?.id))")
                return $0?.id
            }
            .assign(to: \.accountId, on: self)
            .store(in: &cancellables)
        accountRepository.$selectedAccount
            .debounce(for: 0.85, scheduler: RunLoop.main) // Delay the network request
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                print("🟢🔴 \(String(describing: self?.accountId))")
                self?.getTransactions()
            }
            .store(in: &cancellables)
    }
    
    
    func add(_ transaction: FMTransaction) {
        do {
            var newTransaction = transaction
            newTransaction.userId = userId
            newTransaction.accountId = accountId
            
            let batch = store.batch()
            
            let accountRef = store.collection("Account").document(accountRepository.selectedAccount?.id ?? "")
            batch.updateData(["income": (accountRepository.selectedAccount?.income ?? 0.0) + (transaction.value)], forDocument: accountRef)
            
            let newTransactionRef = store.collection(path).document()
            try batch.setData(from: newTransaction, forDocument: newTransactionRef)
            
            batch.commit { error in
                if let error = error {
                    print(error)
                } else {
                    print("Success")
                }
            }
        } catch {
            fatalError("Unable to add card: \(error.localizedDescription).")
        }
    }
    
    func getTransactions() {
        isFetching = true
        transactionQuery = store.collection(path)
            .order(by: "createdAt", descending: true)
            .whereField("userId", isEqualTo: userId)
            .whereField("accountId", isEqualTo: accountId)
            .limit(to: kPaginationCount)
        transactionQuery?.addSnapshotListener { [weak self] (querySnapshot, error) in
                guard let self = self else { return }
                self.isFetching = false
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                let docs = querySnapshot?.documents
                self.lastDocument = docs?.last
            
                self.transactions = docs?.compactMap({ document in
                    try? document.data(as: FMTransaction.self)
                }) ?? []
            }
    }
    
    func fetchNextPage() {
        if let query = transactionQuery, let lastDoc = lastDocument {
            isPaginating = true
            query
                .start(afterDocument: lastDoc)
                .getDocuments { [weak self] (querySnapshot, error) in
                    guard let self = self else { return }
                    self.isPaginating = false
                    
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        let docs = querySnapshot?.documents
                        self.lastDocument = docs?.last
                        
                        let nextBatchTransaction = docs?.compactMap({ document in
                            try? document.data(as: FMTransaction.self)
                        }) ?? []
                        
                        self.transactions.append(contentsOf: nextBatchTransaction)
                    }
                }
        }
    }
    
    func update(transaction: FMTransaction, oldTransaction: FMTransaction) {
        guard let id = transaction.id else { return }
        do {
            let batch = store.batch()
            
            let accountRef = store.collection("Account").document(accountRepository.selectedAccount?.id ?? "")
            
            let accountTransaction = accountRepository.selectedAccount?.income ?? 0.0
            let oldTransactionValue = oldTransaction.value
            let newTransactionValue = transaction.value
            
            let newAccountIncome = (accountTransaction - oldTransactionValue) + newTransactionValue
            
            batch.updateData(["income": newAccountIncome], forDocument: accountRef)
            
            let updateIncomeRef = store.collection(path).document(id)
            try batch.setData(from: transaction, forDocument: updateIncomeRef)
            
            batch.commit { error in
                if let error = error {
                    print(error)
                } else {
                    print("Success")
                }
            }
        } catch {
            print("Unable to update card")
        }
    }
    
    func delete(transaction: FMTransaction) {
        guard let id = transaction.id else { return }
        
        let batch = store.batch()
        
        let accountRef = store.collection("Account").document(accountRepository.selectedAccount?.id ?? "")
        
        let accountIncome = accountRepository.selectedAccount?.income ?? 0.0
        let incomeValue = transaction.value
        let newAccountIncome = accountIncome - incomeValue
        
        batch.updateData(["income": newAccountIncome], forDocument: accountRef)
        
        let deleteIncomeDocRef = store.collection(path).document(id)
        batch.deleteDocument(deleteIncomeDocRef)
        
        batch.commit { error in
            if let error = error {
                print(error)
            } else {
                print("Success")
            }
        }
    }
    
}
