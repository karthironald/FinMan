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
    
    var userId: String?
    var accountId: String?
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
            .map { user in
                user?.uid
            }
            .assign(to: \.userId, on: self)
            .store(in: &cancellables)
        accountRepository.$selectedAccount
            .map {
                print("🟢 \(String(describing: $0?.name)): \(String(describing: $0?.id))")
                return $0?.id
            }
            .assign(to: \.accountId, on: self)
            .store(in: &cancellables)
        accountRepository.$selectedAccount
            .debounce(for: 0.25, scheduler: RunLoop.main) // Delay the network request
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                print("🟢🔴 \(String(describing: self?.accountId))")
                if let accountId = self?.accountId, !accountId.isEmpty  {
                    #warning("No need to fetch transactions when account is selected")
                    // self?.getTransactions()
                } else {
                    self?.resetAllData()
                }
            }
            .store(in: &cancellables)
    }
    
    
    func add(_ transaction: FMTransaction, resultBlock: @escaping (Error?) -> Void) {
        do {
            var newTransaction = transaction
            newTransaction.userId = userId
            newTransaction.accountId = accountId
            
            let batch = store.batch()
            
            let accountRef = store.collection("Account").document(accountRepository.selectedAccount?.id ?? "")
            if newTransaction.transactionType == FMTransaction.TransactionType.income.rawValue {
                batch.updateData(["income": (accountRepository.selectedAccount?.income ?? 0.0) + (transaction.value), "incomeCount": (FMAccountRepository.shared.selectedAccount?.incomeCount ?? 0) + 1], forDocument: accountRef)
            } else {
                batch.updateData(["expense": (accountRepository.selectedAccount?.expense ?? 0.0) + (transaction.value), "expenseCount": (FMAccountRepository.shared.selectedAccount?.expenseCount ?? 0) + 1], forDocument: accountRef)
            }
            
            let newTransactionRef = store.collection(path).document()
            try batch.setData(from: newTransaction, forDocument: newTransactionRef)
            
            batch.commit { error in
                resultBlock(error)
            }
        } catch {
            fatalError("Unable to add card: \(error.localizedDescription).")
        }
    }
    
    func getTransactions() {
        isFetching = true
        transactionQuery = store.collection(path)
            .order(by: "transactionDate", descending: true)
            .whereField("userId", isEqualTo: userId ?? "")
            .whereField("accountId", isEqualTo: accountId ?? "")
            .limit(to: kPaginationCount)
        transactionQuery?.addSnapshotListener { [weak self] (querySnapshot, error) in
            print("🔵🔵")
            guard let self = self else { return }
            if let error = error {
                print(error.localizedDescription)
                self.isFetching = false
                return
            }
            let docs = querySnapshot?.documents
            self.lastDocument = docs?.last
            
            self.transactions = docs?.compactMap({ document in
                try? document.data(as: FMTransaction.self)
            }) ?? []
            self.isFetching = false
        }
    }
    
    func fetchNextPage() {
        if let query = transactionQuery, let lastDoc = lastDocument, transactions.count < FMAccountRepository.shared.totalRecordsCount() {
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
    
    func update(transaction: FMTransaction, oldTransaction: FMTransaction, resultBlock: @escaping (Error?) -> Void) {
        guard let id = transaction.id else { return }
        do {
            let batch = store.batch()
            
            let accountRef = store.collection("Account").document(accountRepository.selectedAccount?.id ?? "")
            
            if transaction.transactionType == FMTransaction.TransactionType.income.rawValue {
                let accountTransaction = accountRepository.selectedAccount?.income ?? 0.0
                let oldTransactionValue = oldTransaction.value
                let newTransactionValue = transaction.value
                
                let newAccountIncome = (accountTransaction - oldTransactionValue) + newTransactionValue
                
                batch.updateData(["income": newAccountIncome], forDocument: accountRef)
            } else {
                let accountTransaction = accountRepository.selectedAccount?.expense ?? 0.0
                let oldTransactionValue = oldTransaction.value
                let newTransactionValue = transaction.value
                
                let newAccountExpense = (accountTransaction - oldTransactionValue) + newTransactionValue
                
                batch.updateData(["expense": newAccountExpense], forDocument: accountRef)
            }
            
            let updateIncomeRef = store.collection(path).document(id)
            try batch.setData(from: transaction, forDocument: updateIncomeRef)
            
            batch.commit { error in
                resultBlock(error)
            }
        } catch {
            print("Unable to update card")
        }
    }
    
    func delete(transaction: FMTransaction, resultBlock: @escaping (Error?) -> Void) {
        guard let id = transaction.id else { return }
        
        let batch = store.batch()
        
        let accountRef = store.collection("Account").document(accountRepository.selectedAccount?.id ?? "")
        
        if transaction.transactionType == FMTransaction.TransactionType.income.rawValue {
            let accountIncome = accountRepository.selectedAccount?.income ?? 0.0
            let incomeValue = transaction.value
            let newAccountIncome = accountIncome - incomeValue
            
            batch.updateData(["income": newAccountIncome, "incomeCount": (FMAccountRepository.shared.selectedAccount?.incomeCount ?? 0) - 1], forDocument: accountRef)
        } else {
            let accountExpense = accountRepository.selectedAccount?.expense ?? 0.0
            let expenseValue = transaction.value
            let newAccountExpense = accountExpense - expenseValue
            
            batch.updateData(["expense": newAccountExpense, "expenseCount": (FMAccountRepository.shared.selectedAccount?.expenseCount ?? 0) - 1], forDocument: accountRef)
        }
        
        let deleteIncomeDocRef = store.collection(path).document(id)
        batch.deleteDocument(deleteIncomeDocRef)
        
        batch.commit { error in
            resultBlock(error)
        }
    }
    
    func log(startDate: Date, endDate: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        print("🔵⭐️ \(dateFormatter.string(from: startDate)) to \(dateFormatter.string(from: endDate))")
    }
    
    func filterTransaction(startDate: Date, endDate: Date, incomeSource: FMTransaction.IncomeSource? = nil, transactionType: FMTransaction.TransactionType? = nil) {
        log(startDate: startDate, endDate: endDate)
        isFetching = true
        transactionQuery = store.collection(path)
            .order(by: "transactionDate", descending: true)
            .whereField("userId", isEqualTo: userId ?? "")
            .whereField("accountId", isEqualTo: accountId ?? "")
            .whereField("transactionDate", isGreaterThanOrEqualTo: startDate)
            .whereField("transactionDate", isLessThanOrEqualTo: endDate)
            .limit(to: kPaginationCount)

        if let source = incomeSource {
            transactionQuery = transactionQuery?.whereField("source", isEqualTo: source.rawValue)
        }
        
        if let transactionType = transactionType {
            transactionQuery = transactionQuery?.whereField("transactionType", isEqualTo: transactionType.rawValue)
        }
        
        transactionQuery?.getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            if let error = error {
                print(error.localizedDescription)
                self.isFetching = false
                return
            }
            let docs = querySnapshot?.documents
            self.lastDocument = docs?.last
            print("🔵⭐️ \(docs?.count ?? 0)")
            self.transactions = docs?.compactMap({ document in
                try? document.data(as: FMTransaction.self)
            }) ?? []
            self.isFetching = false
        }
    }
    
    func resetAllData() {
        transactions = []
    }
    
}
