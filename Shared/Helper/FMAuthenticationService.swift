//
//  FMAuthenticationService.swift
//  FinMan
//
//  Created by Karthick Selvaraj on 26/04/21.
//
import Foundation
import Firebase
import Alamofire


class FMAuthenticationService: ObservableObject {
    
    static let shared = FMAuthenticationService()
    private var authStateDidChangeHandler: AuthStateDidChangeListenerHandle?
    
    @Published var user: FMUser?
    
    // MARK: - Init Methods
    
    private init() { }
    
    
    // MARK: - Custom methods
    
    
    func signup(with email: String?, password: String?, successBlock: @escaping (Bool) -> Void, failureBlock: @escaping (Error?) -> Void) {
        guard let email = email, let password = password else {
            failureBlock(nil)
            return
        }
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                failureBlock(error)
            } else {
                successBlock(true)
            }
        }
    }
    
    func signin(with email: String?, password: String?, successBlock: @escaping (Bool) -> Void, failureBlock: @escaping (Error?) -> Void) {
        guard let email = email, let password = password else {
            failureBlock(nil)
            return
        }
        AF.request("\(kBaseUrl)/api/login", method: .post, parameters: ["username": email, "password": password], encoder: .json, headers: nil, interceptor: nil, requestModifier: nil).responseDecodable(of: Token.self) { response in
            print(response)
            switch response.result {
            case.success(let token):
                _ = MTKeychainManager.sharedInstance.save(value: token.access, for: .accessToken)
                _ = MTKeychainManager.sharedInstance.save(value: token.refresh, for: .refreshToken)
                AF.request("\(kBaseUrl)/api/profile", method: .get, headers: ["Authorization": "Bearer \(token.access)"]).responseDecodable(of: FMUser.self) { response in
                    switch response.result {
                    case .success(let user):
                        self.user = user
                        successBlock(true)
                    case .failure(let error):
                        print(error)
                        failureBlock(error)
                    }
                }
            case .failure(let error):
                failureBlock(error)
            }
        }
    }
    
    func signOut() {
        MTKeychainManager.sharedInstance.deleteValue(for: .accessToken)
        MTKeychainManager.sharedInstance.deleteValue(for: .refreshToken)
    }
    
    func initiateRestPassword(for email: String?, successBlock: @escaping (Bool) -> Void, failureBlock: @escaping (Error?) -> Void) {
        guard let email = email else {
            failureBlock(nil)
            return
        }
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                failureBlock(error)
            } else {
                successBlock(true)
            }
        }
    }
    
}
