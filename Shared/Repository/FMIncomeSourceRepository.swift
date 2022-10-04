//
//  FMIncomeSourceRepository.swift
//  FinMan (iOS)
//
//  Created by Karthick Selvaraj on 24/08/22.
//

import Foundation
import Combine
import Alamofire

class FMIncomeSourceRepository: ObservableObject {
        
    @Published var sources: [FMDIncomeSource] = []
    @Published var isFetching: Bool = false
    
    func getIncomeSources() {
        isFetching = true
        
        let decoder = JSONDecoder()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        decoder.dateDecodingStrategy = .formatted(formatter)
        
        if let token = MTKeychainManager.sharedInstance.value(for: .accessToken) {
            AF.request("\(kBaseUrl)/api/income_source/", method: .get, headers: ["Authorization": "Bearer \(token)"]).validate().responseDecodable(of: FMIncomeSourceResponse.self, decoder: decoder) { [weak self] response in
                switch response.result {
                case .success(let transactionResponse):
                    self?.sources = transactionResponse.results ?? []
                case .failure(let error):
                    print(error)
                }
                self?.isFetching = false
            }
        }
    }
    
}

