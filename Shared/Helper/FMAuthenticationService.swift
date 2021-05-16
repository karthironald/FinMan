//
//  FMAuthenticationService.swift
//  FinMan
//
//  Created by Karthick Selvaraj on 26/04/21.
//
import Foundation
import Firebase

class FMAuthenticationService: ObservableObject {
    
    static let shared = FMAuthenticationService()
    @Published var user: User?
    private var authStateDidChangeHandler: AuthStateDidChangeListenerHandle?
    
    // MARK: - Init Methods
    
    private init() {
        addListener()
    }
    
    // MARK: - Custom methods
    
    func addListener() {
        if let handler = authStateDidChangeHandler {
            Auth.auth().removeStateDidChangeListener(handler)
        }
        authStateDidChangeHandler = Auth.auth().addStateDidChangeListener({ (_, user) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.user = user
            }
        })
    }
    
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
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                failureBlock(error)
            } else {
                successBlock(true)
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print(error)
        }
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
