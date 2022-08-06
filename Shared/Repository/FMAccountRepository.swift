//
//  FMAccountRepository.swift
//  FinMan
//
//  Created by Karthick Selvaraj on 02/05/21.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine
import Alamofire

class FMAccountRepository: ObservableObject {
    
    static let shared = FMAccountRepository()
    private let path: String = FMFirestoreCollection.account.rawValue
    private let store = Firestore.firestore()
    private var userId: Int?
    private let authenticationService = FMAuthenticationService.shared
    private var cancellables: Set<AnyCancellable> = []
    
    @Published var accounts: [FMAccount] = []
    @Published var selectedAccount: FMAccount?
    @Published var isFetching: Bool = false
    
    
    // MARK: - Init Methods
    
    private init() {
        authenticationService.$user
            .map { user in
                user?.id
            }
            .assign(to: \.userId, on: self)
            .store(in: &cancellables)
        
        authenticationService.$user
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                if let userId = self?.userId {
                    self?.getAccounts()
                } else {
                    self?.resetAllData()
                }
            }
            .store(in: &cancellables)
    }
    
    
    // MARK: - Custom methods
    
    func add(name: String, comments: String?, resultBlock: @escaping (Error?) -> Void) {
        if let token = UserDefaults.standard.value(forKey: "access_token") as? String {
            AF.request("\(kBaseUrl)/api/accounts/", method: .post, parameters: ["name": name, "description": comments], encoder: .json, headers: ["Authorization": "Bearer \(token)"]).validate().responseDecodable(of: FMAccount.self) { response in
                switch response.result {
                case .success(let account):
                    self.accounts.append(account)
                    resultBlock(nil)
                case .failure(let error):
                    print(error)
                    resultBlock(error)
                }
            }
        }
    }
    
    func getAccounts() {
        isFetching = true
        
        if let token = UserDefaults.standard.value(forKey: "access_token") as? String {
            AF.request("\(kBaseUrl)/api/accounts/", method: .get, headers: ["Authorization": "Bearer \(token)"]).validate().responseDecodable(of: FMAccountsResponse.self) { [weak self] response in
                switch response.result {
                case .success(let accountResponse):
                    self?.accounts = accountResponse.results ?? []
                case .failure(let error):
                    print(error)
                }
                self?.isFetching = false
            }
        }
    }
    
    func update(id: Int?, name: String?, comments: String?, resultBlock: @escaping (Error?) -> Void) {
        if let token = UserDefaults.standard.value(forKey: "access_token") as? String, let id = id {
            AF.request("\(kBaseUrl)/api/accounts/\(id)/", method: .patch, parameters: ["name": name, "description": comments ?? ""], encoder: .json, headers: ["Authorization": "Bearer \(token)"]).validate().responseDecodable(of: FMAccount.self) { response in
                switch response.result {
                case .success(let account):
                    if let index = self.accounts.firstIndex(where: { $0.id == id }) {
                        self.accounts[index] = account
                    }
                    resultBlock(nil)
                case .failure(let error):
                    print(error)
                    resultBlock(error)
                }
            }
        }
    }
    
    func delete(id: Int?, resultBlock: @escaping (Error?) -> Void) {
        if let token = UserDefaults.standard.value(forKey: "access_token") as? String, let id = id {
            AF.request("\(kBaseUrl)/api/accounts/\(id)/", method: .delete, headers: ["Authorization": "Bearer \(token)"]).validate().response { response in
                switch response.result {
                case .success(_):
                    if let index = self.accounts.firstIndex(where: { $0.id == id }) {
                        self.accounts.remove(at: index)
                    }
                    resultBlock(nil)
                case .failure(let error):
                    resultBlock(error)
                }
            }
        }
    }
    
    func totalRecordsCount() -> Int64 {
        0
    }
    
    func resetAllData() {
        accounts = []
        selectedAccount = nil
    }
    
}


