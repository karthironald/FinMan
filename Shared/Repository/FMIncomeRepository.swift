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
    
    private let path: String = "Income"
    private let store = Firestore.firestore()
    
    var userId = ""
    private let authenticationService = FMAuthenticationService.shared
    private var cancellables: Set<AnyCancellable> = []
    
    @Published var incomes: [FMIncome] = []
    @Published var isFetching: Bool = false
    
    init() {
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
    }
    
    
    func add(_ income: FMIncome) {
        do {
            var newIncome = income
            newIncome.userId = userId
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
            .addSnapshotListener { [self] (querySnapshot, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                self.incomes = querySnapshot?.documents.compactMap({ document in
                    try? document.data(as: FMIncome.self)
                }) ?? []
                isFetching = false
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
