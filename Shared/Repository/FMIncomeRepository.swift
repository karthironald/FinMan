//
//  FMIncomeRepository.swift
//  FinMan
//
//  Created by Karthick Selvaraj on 26/04/21.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

let kPaginationCount = 5

class FMIncomeRepository: ObservableObject {
    
    static let shared = FMIncomeRepository()
    private let path: String = "Income"
    private let store = Firestore.firestore()
    
    var userId = ""
    var accountId = ""
    private let authenticationService = FMAuthenticationService.shared
    private let accountRepository = FMAccountRepository.shared
    private var cancellables: Set<AnyCancellable> = []
    
    @Published var incomes: [FMIncome] = []
    @Published var isFetching: Bool = false
    @Published var isPaginating: Bool = false
    
    var lastDocument: DocumentSnapshot?
    var incomeQuery: Query?
    
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
                self?.getIncomes()
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
                self?.getIncomes()
            }
            .store(in: &cancellables)
    }
    
    
    func add(_ income: FMIncome) {
        do {
            var newIncome = income
            newIncome.userId = userId
            newIncome.accountId = accountId
            
            let batch = store.batch()
            
            let accountRef = store.collection("Account").document(accountRepository.selectedAccount?.id ?? "")
            batch.updateData(["income": (accountRepository.selectedAccount?.income ?? 0.0) + (income.value)], forDocument: accountRef)
            
            let newIncomeRef = store.collection(path).document()
            try batch.setData(from: newIncome, forDocument: newIncomeRef)
            
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
    
    func getIncomes() {
        isFetching = true
        incomeQuery = store.collection(path)
            .order(by: "createdAt", descending: true)
            .whereField("userId", isEqualTo: userId)
            .whereField("accountId", isEqualTo: accountId)
            .limit(to: kPaginationCount)
        incomeQuery?.addSnapshotListener { [weak self] (querySnapshot, error) in
                guard let self = self else { return }
                self.isFetching = false
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                let docs = querySnapshot?.documents
                self.lastDocument = docs?.last
            
                self.incomes = docs?.compactMap({ document in
                    try? document.data(as: FMIncome.self)
                }) ?? []
            }
    }
    
    func fetchNextPage() {
        if let query = incomeQuery, let lastDoc = lastDocument {
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
                        
                        let nextBatchIncome = docs?.compactMap({ document in
                            try? document.data(as: FMIncome.self)
                        }) ?? []
                        
                        self.incomes.append(contentsOf: nextBatchIncome)
                    }
                }
        }
    }
    
    func update(income: FMIncome, oldIncome: FMIncome) {
        guard let id = income.id else { return }
        do {
            let batch = store.batch()
            
            let accountRef = store.collection("Account").document(accountRepository.selectedAccount?.id ?? "")
            
            let accountIncome = accountRepository.selectedAccount?.income ?? 0.0
            let oldIncomeValue = oldIncome.value
            let newIncomeValue = income.value
            
            let newAccountIncome = (accountIncome - oldIncomeValue) + newIncomeValue
            
            batch.updateData(["income": newAccountIncome], forDocument: accountRef)
            
            let updateIncomeRef = store.collection(path).document(id)
            try batch.setData(from: income, forDocument: updateIncomeRef)
            
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
    
    func delete(income: FMIncome) {
        guard let id = income.id else { return }
        
        let batch = store.batch()
        
        let accountRef = store.collection("Account").document(accountRepository.selectedAccount?.id ?? "")
        
        let accountIncome = accountRepository.selectedAccount?.income ?? 0.0
        let incomeValue = income.value
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
