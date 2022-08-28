//
//  FMTransactionRepository.swift
//  FinMan
//
//  Created by Karthick Selvaraj on 26/04/21.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine
import Alamofire

let kPaginationCount = 100

class FMTransactionRepository: ObservableObject {
    
    static let shared = FMTransactionRepository()
    private let path: String = FMFirestoreCollection.transaction.rawValue
    private let store = Firestore.firestore()
    
    private var userId: Int?
    private var accountId: Int?
    private let authenticationService = FMAuthenticationService.shared
    private let accountRepository = FMAccountRepository.shared
    private var cancellables: Set<AnyCancellable> = []
    private var lastDocument: DocumentSnapshot?
    private var transactionQuery: Query?
    
    @Published var transactions: [FMTransaction] = []
    @Published var isFetching: Bool = false
    @Published var isPaginating: Bool = false
    
    
    // MARK: - Init Methods
    
    private init() {
        authenticationService.$user
            .map { user in
                user?.id
            }
            .assign(to: \.userId, on: self)
            .store(in: &cancellables)
        accountRepository.$selectedAccount
            .map { $0?.id }
            .assign(to: \.accountId, on: self)
            .store(in: &cancellables)
        accountRepository.$selectedAccount
            .debounce(for: 0.25, scheduler: RunLoop.main) // Delay the network request
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                if let accountId = self?.accountId {
                    #warning("No need to fetch transactions when account is selected")
                    // self?.getTransactions()
                } else {
                    self?.resetAllData()
                }
            }
            .store(in: &cancellables)
    }
    
    
    // MARK: - Custom methods
    
    /**
     Adds new transaction
     
     Adds new transaction against the selected account in the firestore
     
     - Parameters:
        - transaction: Transaction to add
        - resultBlock: Callback to be triggered as result of save action
     */
    func add(_ transaction: FMAddTransactionRequest, resultBlock: @escaping (Error?) -> Void) {
//        do {
//            var newTransaction = transaction
//            newTransaction.userId = userId
//            newTransaction.accountId = accountId
//
//            let batch = store.batch()
//
//            let accountRef = store.collection(FMFirestoreCollection.account.rawValue).document(accountRepository.selectedAccount?.id ?? "")
//            if newTransaction.transactionType == FMTransaction.TransactionType.income.rawValue {
//                batch.updateData([FMAccount.Keys.income.rawValue: (accountRepository.selectedAccount?.income ?? 0.0) + (transaction.value), FMAccount.Keys.incomeCount.rawValue: (FMAccountRepository.shared.selectedAccount?.incomeCount ?? 0) + 1], forDocument: accountRef)
//            } else {
//                batch.updateData([FMAccount.Keys.expense.rawValue: (accountRepository.selectedAccount?.expense ?? 0.0) + (transaction.value), FMAccount.Keys.expenseCount.rawValue: (FMAccountRepository.shared.selectedAccount?.expenseCount ?? 0) + 1], forDocument: accountRef)
//            }
//
//            let newTransactionRef = store.collection(path).document()
//            try batch.setData(from: newTransaction, forDocument: newTransactionRef)
//
//            batch.commit { error in
//                resultBlock(error)
//            }
//        } catch {
//            fatalError("Unable to add card: \(error.localizedDescription).")
//        }
    }
    
    func getTransactions() {
        isFetching = true
        transactionQuery = store.collection(path)
            .order(by: FMTransaction.Keys.transactionDate.rawValue, descending: true)
            .whereField(FMTransaction.Keys.userId.rawValue, isEqualTo: userId ?? "")
            .whereField(FMTransaction.Keys.accountId.rawValue, isEqualTo: accountId ?? "")
            .limit(to: kPaginationCount)
        transactionQuery?.addSnapshotListener { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            if error != nil {
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
//        guard let id = transaction.id else { return }
//        do {
//            let batch = store.batch()
//
//            let accountRef = store.collection(FMFirestoreCollection.account.rawValue).document(accountRepository.selectedAccount?.id ?? "")
//
//            if transaction.transactionType == FMTransaction.TransactionType.income.rawValue {
//                let accountTransaction = accountRepository.selectedAccount?.income ?? 0.0
//                let oldTransactionValue = oldTransaction.value
//                let newTransactionValue = transaction.value
//
//                let newAccountIncome = (accountTransaction - oldTransactionValue) + newTransactionValue
//
//                batch.updateData([FMAccount.Keys.income.rawValue: newAccountIncome], forDocument: accountRef)
//            } else {
//                let accountTransaction = accountRepository.selectedAccount?.expense ?? 0.0
//                let oldTransactionValue = oldTransaction.value
//                let newTransactionValue = transaction.value
//
//                let newAccountExpense = (accountTransaction - oldTransactionValue) + newTransactionValue
//
//                batch.updateData([FMAccount.Keys.expense.rawValue: newAccountExpense], forDocument: accountRef)
//            }
//
//            let updateIncomeRef = store.collection(path).document(id)
//            try batch.setData(from: transaction, forDocument: updateIncomeRef)
//
//            batch.commit { error in
//                resultBlock(error)
//            }
//        } catch {
//            print("Unable to update card")
//        }
    }
    
    func delete(transaction: FMTransaction, resultBlock: @escaping (Error?) -> Void) {
//        guard let id = transaction.id else { return }
//        
//        let batch = store.batch()
//        
//        let accountRef = store.collection(FMFirestoreCollection.account.rawValue).document(accountRepository.selectedAccount?.id ?? "")
//        
//        if transaction.transactionType == FMTransaction.TransactionType.income.rawValue {
//            let accountIncome = accountRepository.selectedAccount?.income ?? 0.0
//            let incomeValue = transaction.value
//            let newAccountIncome = accountIncome - incomeValue
//            
//            batch.updateData([FMAccount.Keys.income.rawValue: newAccountIncome, FMAccount.Keys.incomeCount.rawValue: (FMAccountRepository.shared.selectedAccount?.incomeCount ?? 0) - 1], forDocument: accountRef)
//        } else {
//            let accountExpense = accountRepository.selectedAccount?.expense ?? 0.0
//            let expenseValue = transaction.value
//            let newAccountExpense = accountExpense - expenseValue
//            
//            batch.updateData([FMAccount.Keys.expense.rawValue: newAccountExpense, FMAccount.Keys.expenseCount.rawValue: (FMAccountRepository.shared.selectedAccount?.expenseCount ?? 0) - 1], forDocument: accountRef)
//        }
//        
//        let deleteIncomeDocRef = store.collection(path).document(id)
//        batch.deleteDocument(deleteIncomeDocRef)
//        
//        batch.commit { error in
//            resultBlock(error)
//        }
    }
    
    func filterTransaction(startDate: Date, endDate: Date, incomeSource: FMTransaction.IncomeSource? = nil, transactionType: FMTransaction.TransactionType? = nil) {
        isFetching = true
        transactionQuery = store.collection(path)
            .order(by: FMTransaction.Keys.transactionDate.rawValue, descending: true)
            .whereField(FMTransaction.Keys.userId.rawValue, isEqualTo: userId ?? "")
            .whereField(FMTransaction.Keys.accountId.rawValue, isEqualTo: accountId ?? "")
            .whereField(FMTransaction.Keys.transactionDate.rawValue, isGreaterThanOrEqualTo: startDate)
            .whereField(FMTransaction.Keys.transactionDate.rawValue, isLessThanOrEqualTo: endDate)
            .limit(to: kPaginationCount)

        if let source = incomeSource {
            transactionQuery = transactionQuery?.whereField(FMTransaction.Keys.source.rawValue, isEqualTo: source.rawValue)
        }
        
        if let transactionType = transactionType {
            transactionQuery = transactionQuery?.whereField(FMTransaction.Keys.transactionType.rawValue, isEqualTo: transactionType.rawValue)
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


class FMDTransactionRepository: ObservableObject {
    
    static let shared = FMDTransactionRepository()
    
    private var userId: Int?
    private var accountId: Int?
    private let authenticationService = FMAuthenticationService.shared
    private let accountRepository = FMAccountRepository.shared
    private var cancellables: Set<AnyCancellable> = []
    
    @Published var transactions: [FMDTransaction] = []
    @Published var isFetching: Bool = false
    @Published var isPaginating: Bool = false
    @Published var nextPageUrl: String? = nil
    
    
    // MARK: - Init Methods
    
    private init() {
        authenticationService.$user
            .map { user in
                user?.id
            }
            .assign(to: \.userId, on: self)
            .store(in: &cancellables)
        accountRepository.$selectedAccount
            .map { $0?.id }
            .assign(to: \.accountId, on: self)
            .store(in: &cancellables)
        accountRepository.$selectedAccount
            .debounce(for: 0.25, scheduler: RunLoop.main) // Delay the network request
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                if let accountId = self?.accountId {
                    #warning("No need to fetch transactions when account is selected")
                    // self?.getTransactions()
                } else {
                    self?.resetAllData()
                }
            }
            .store(in: &cancellables)
    }
    
    
    // MARK: - Custom methods
    
    /**
     Adds new transaction
     
     Adds new transaction against the selected account in the firestore
     
     - Parameters:
        - transaction: Transaction to add
        - resultBlock: Callback to be triggered as result of save action
     */
    func add(_ transaction: FMAddTransactionRequest, resultBlock: @escaping (Error?) -> Void) {
        let decoder = JSONDecoder()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        decoder.dateDecodingStrategy = .formatted(formatter)
        
        if let token = UserDefaults.standard.value(forKey: "access_token") as? String {
            AF.request("\(kBaseUrl)/api/transactions/", method: .post, parameters: transaction, headers: ["Authorization": "Bearer \(token)"]).validate().responseDecodable(of: FMDTransaction.self, decoder: decoder) { [weak self] response in
                switch response.result {
                case .success(let transactionResponse):
                    print(transactionResponse)
                    resultBlock(nil)
                case .failure(let error):
                    print(error)
                    resultBlock(error)
                }
            }
        }
    }
    
    func getTransactions() {
        isFetching = true
        
        let decoder = JSONDecoder()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        decoder.dateDecodingStrategy = .formatted(formatter)
        
        if let token = UserDefaults.standard.value(forKey: "access_token") as? String {
            AF.request("\(kBaseUrl)/api/transactions/", method: .get, headers: ["Authorization": "Bearer \(token)"]).validate().responseDecodable(of: FMDTransactionResponse.self, decoder: decoder) { [weak self] response in
                switch response.result {
                case .success(let transactionResponse):
                    self?.transactions = transactionResponse.results ?? []
                    self?.nextPageUrl = transactionResponse.next
                case .failure(let error):
                    print(error)
                }
                self?.isFetching = false
            }
        }
    }
    
    func fetchNextPage() {
        if let nextPageUrl = nextPageUrl {
            isPaginating = true
            if let token = UserDefaults.standard.value(forKey: "access_token") as? String {
                let decoder = JSONDecoder()
                
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                formatter.timeZone = TimeZone(abbreviation: "UTC")
                decoder.dateDecodingStrategy = .formatted(formatter)
                
                AF.request(nextPageUrl, method: .get, headers: ["Authorization": "Bearer \(token)"]).validate().responseDecodable(of: FMDTransactionResponse.self, decoder: decoder) { [weak self] response in
                    switch response.result {
                    case .success(let transactionResponse):
                        self?.transactions.append(contentsOf: transactionResponse.results ?? [])
                        self?.nextPageUrl = transactionResponse.next
                    case .failure(let error):
                        print(error)
                    }
                    self?.isPaginating = false
                }
            }
        }
    }
    
    func update(transaction: FMTransaction, oldTransaction: FMTransaction, resultBlock: @escaping (Error?) -> Void) {
//        guard let id = transaction.id else { return }
//        do {
//            let batch = store.batch()
//
//            let accountRef = store.collection(FMFirestoreCollection.account.rawValue).document(accountRepository.selectedAccount?.id ?? "")
//
//            if transaction.transactionType == FMTransaction.TransactionType.income.rawValue {
//                let accountTransaction = accountRepository.selectedAccount?.income ?? 0.0
//                let oldTransactionValue = oldTransaction.value
//                let newTransactionValue = transaction.value
//
//                let newAccountIncome = (accountTransaction - oldTransactionValue) + newTransactionValue
//
//                batch.updateData([FMAccount.Keys.income.rawValue: newAccountIncome], forDocument: accountRef)
//            } else {
//                let accountTransaction = accountRepository.selectedAccount?.expense ?? 0.0
//                let oldTransactionValue = oldTransaction.value
//                let newTransactionValue = transaction.value
//
//                let newAccountExpense = (accountTransaction - oldTransactionValue) + newTransactionValue
//
//                batch.updateData([FMAccount.Keys.expense.rawValue: newAccountExpense], forDocument: accountRef)
//            }
//
//            let updateIncomeRef = store.collection(path).document(id)
//            try batch.setData(from: transaction, forDocument: updateIncomeRef)
//
//            batch.commit { error in
//                resultBlock(error)
//            }
//        } catch {
//            print("Unable to update card")
//        }
    }
    
    func delete(transaction: FMTransaction, resultBlock: @escaping (Error?) -> Void) {
//        guard let id = transaction.id else { return }
//
//        let batch = store.batch()
//
//        let accountRef = store.collection(FMFirestoreCollection.account.rawValue).document(accountRepository.selectedAccount?.id ?? "")
//
//        if transaction.transactionType == FMTransaction.TransactionType.income.rawValue {
//            let accountIncome = accountRepository.selectedAccount?.income ?? 0.0
//            let incomeValue = transaction.value
//            let newAccountIncome = accountIncome - incomeValue
//
//            batch.updateData([FMAccount.Keys.income.rawValue: newAccountIncome, FMAccount.Keys.incomeCount.rawValue: (FMAccountRepository.shared.selectedAccount?.incomeCount ?? 0) - 1], forDocument: accountRef)
//        } else {
//            let accountExpense = accountRepository.selectedAccount?.expense ?? 0.0
//            let expenseValue = transaction.value
//            let newAccountExpense = accountExpense - expenseValue
//
//            batch.updateData([FMAccount.Keys.expense.rawValue: newAccountExpense, FMAccount.Keys.expenseCount.rawValue: (FMAccountRepository.shared.selectedAccount?.expenseCount ?? 0) - 1], forDocument: accountRef)
//        }
//
//        let deleteIncomeDocRef = store.collection(path).document(id)
//        batch.deleteDocument(deleteIncomeDocRef)
//
//        batch.commit { error in
//            resultBlock(error)
//        }
    }
    
    func filterTransaction(startDate: Date, endDate: Date, incomeSource: FMTransaction.IncomeSource? = nil, transactionType: FMTransaction.TransactionType? = nil) {
//        isFetching = true
//        transactionQuery = store.collection(path)
//            .order(by: FMTransaction.Keys.transactionDate.rawValue, descending: true)
//            .whereField(FMTransaction.Keys.userId.rawValue, isEqualTo: userId ?? "")
//            .whereField(FMTransaction.Keys.accountId.rawValue, isEqualTo: accountId ?? "")
//            .whereField(FMTransaction.Keys.transactionDate.rawValue, isGreaterThanOrEqualTo: startDate)
//            .whereField(FMTransaction.Keys.transactionDate.rawValue, isLessThanOrEqualTo: endDate)
//            .limit(to: kPaginationCount)
//
//        if let source = incomeSource {
//            transactionQuery = transactionQuery?.whereField(FMTransaction.Keys.source.rawValue, isEqualTo: source.rawValue)
//        }
//        
//        if let transactionType = transactionType {
//            transactionQuery = transactionQuery?.whereField(FMTransaction.Keys.transactionType.rawValue, isEqualTo: transactionType.rawValue)
//        }
//        
//        transactionQuery?.getDocuments { [weak self] (querySnapshot, error) in
//            guard let self = self else { return }
//            if let error = error {
//                print(error.localizedDescription)
//                self.isFetching = false
//                return
//            }
//            let docs = querySnapshot?.documents
//            self.lastDocument = docs?.last
//            print("🔵⭐️ \(docs?.count ?? 0)")
//            self.transactions = docs?.compactMap({ document in
//                try? document.data(as: FMTransaction.self)
//            }) ?? []
//            self.isFetching = false
//        }
    }
    
    func resetAllData() {
        transactions = []
    }
 
    func shouldLoadMore() -> Bool {
        (nextPageUrl != nil)
    }
}

