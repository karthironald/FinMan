//
//  FMExpenseCategoryRepository.swift
//  FinMan (iOS)
//
//  Created by Karthick Selvaraj on 28/08/22.
//

import Foundation
import Alamofire

class FMExpenseCategoryRepository: ObservableObject {
        
    @Published var category: [FMDExpenseCategory] = []
    @Published var isFetching: Bool = false
    
    func getExpenseCategory() {
        isFetching = true
        
        let decoder = JSONDecoder()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        decoder.dateDecodingStrategy = .formatted(formatter)
        
        if let token = MTKeychainManager.sharedInstance.value(for: .accessToken) {
            AF.request("\(kBaseUrl)/api/expense_category/", method: .get, headers: ["Authorization": "Bearer \(token)"]).validate().responseDecodable(of: FMExpenseCategoryResponse.self, decoder: decoder) { [weak self] response in
                switch response.result {
                case .success(let transactionResponse):
                    self?.category = transactionResponse.results ?? []
                case .failure(let error):
                    print(error)
                }
                self?.isFetching = false
            }
        }
    }
}

class FMEventRepository: ObservableObject {
        
    @Published var events: [FMEvent] = []
    @Published var isFetching: Bool = false
    
    func getEvents() {
        isFetching = true
        
        let decoder = JSONDecoder()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        decoder.dateDecodingStrategy = .formatted(formatter)
        
        if let token = MTKeychainManager.sharedInstance.value(for: .accessToken) {
            AF.request("\(kBaseUrl)/api/events/", method: .get, headers: ["Authorization": "Bearer \(token)"]).validate().responseDecodable(of: FMEventsResponse.self, decoder: decoder) { [weak self] response in
                switch response.result {
                case .success(let transactionResponse):
                    self?.events = transactionResponse.results ?? []
                case .failure(let error):
                    print(error)
                }
                self?.isFetching = false
            }
        }
    }
    
    func add(name: String, comments: String?, resultBlock: @escaping (Error?) -> Void) {
        if let token = MTKeychainManager.sharedInstance.value(for: .accessToken) {
            AF.request("\(kBaseUrl)/api/events/", method: .post, parameters: ["name": name, "description": comments], encoder: .json, headers: ["Authorization": "Bearer \(token)"]).validate().responseDecodable(of: FMEvent.self) { response in
                switch response.result {
                case .success(let account):
                    self.events.append(account)
                    resultBlock(nil)
                case .failure(let error):
                    print(error)
                    resultBlock(error)
                }
            }
        }
    }
}
