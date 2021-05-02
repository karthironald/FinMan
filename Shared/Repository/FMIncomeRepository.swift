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
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.getIncomes()
            }
            .store(in: &cancellables)
        accountRepository.$selectedAccount
            .compactMap {
                print("🟢 \($0?.name): \($0?.id)")
                return $0?.id
            }
            .assign(to: \.accountId, on: self)
            .store(in: &cancellables)
        accountRepository.$selectedAccount
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                print("🟢🔴 \(self?.accountId)")
                self?.getIncomes()
            }
            .store(in: &cancellables)
    }
    
    
    func add(_ income: FMIncome) {
        do {
            var newIncome = income
            newIncome.userId = userId
            newIncome.accountId = accountId
            _ = try store.collection(path).addDocument(from: newIncome)
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
    
    func update(income: FMIncome) {
        guard let id = income.id else { return }
        do {
            try store.collection(path).document(id).setData(from: income)
        } catch {
            print("Unable to update card")
        }
    }
    
    func delete(income: FMIncome) {
        guard let id = income.id else { return }
        store.collection(path).document(id).delete(completion: { (error) in
            if let error = error {
                print(error.localizedDescription)
            }
        })
    }
    
}
