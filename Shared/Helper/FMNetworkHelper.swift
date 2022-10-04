//
//  FMNetworkHelper.swift
//  FinMan (iOS)
//
//  Created by Karthick Selvaraj on 24/08/22.
//

import Foundation
import Alamofire

class FMNetworkHelper {
    
    static let shared = FMNetworkHelper()
    
    private init() { }
    
    func apiRequest<T: Decodable, P: Encodable>(url: URL, method: HTTPMethod, paramater: P?, headers: HTTPHeaders?, decodable: T.Type, resultBlock: @escaping (Result<Decodable, Error>) -> Void) {
        
        let decoder = JSONDecoder()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        decoder.dateDecodingStrategy = .formatted(formatter)
        
        AF.request(url, method: method, parameters: paramater, headers: headers).validate().responseDecodable(of: T.self, decoder: decoder) { response in
            switch response.result {
            case .success(let data):
                resultBlock(.success(data))
            case .failure(let error):
                resultBlock(.failure(error))
            }
        }
    }
    
    func get<T: Decodable, P: Encodable>(url: URL, paramater: P?, headers: HTTPHeaders, decodable: T.Type, resultBlock: @escaping (Result<Decodable, Error>) -> Void) {
        apiRequest(url: url, method: .get, paramater: paramater, headers: updatedHeaders(headers: headers), decodable: decodable, resultBlock: resultBlock)
    }
    
    func post<T: Decodable, P: Encodable>(url: URL, paramater: P?, headers: HTTPHeaders, decodable: T.Type, resultBlock: @escaping (Result<Decodable, Error>) -> Void) {
        apiRequest(url: url, method: .post, paramater: paramater, headers: updatedHeaders(headers: headers), decodable: decodable, resultBlock: resultBlock)
    }
    
    private func updatedHeaders(headers: HTTPHeaders) -> HTTPHeaders {
        if let token = MTKeychainManager.sharedInstance.value(for: .accessToken) {
            var updatedHeaders = headers
            updatedHeaders["Authorization"] = "Bearer \(token)"
            return updatedHeaders
        }
        return headers
    }
    
}
