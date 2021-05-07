//
//  FMIncomeRepository.swift
//  FinMan
//
//  Created by Karthick Selvaraj on 26/04/21.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

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
        store.collection(path)
            .order(by: "createdAt", descending: true)
            .whereField("userId", isEqualTo: userId)
            .whereField("accountId", isEqualTo: accountId)
            .addSnapshotListener { [weak self] (querySnapshot, error) in
                guard let self = self else { return }
                if let error = error {
                    print(error.localizedDescription)
                    self.isFetching = false
                    return
                }
                self.incomes = querySnapshot?.documents.compactMap({ document in
                    try? document.data(as: FMIncome.self)
                }) ?? []
                self.isFetching = false
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
