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
            self.user = user
        })
    }
    
    func signup(with email: String?, password: String?, status: @escaping (Bool) -> Void) {
        guard let email = email, let password = password else { return }
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print(error.localizedDescription)
                status(false)
            } else {
                print(result)
                self.user = result?.user
                status(true)
            }
        }
    }
    
    func signin(with email: String?, password: String?, status: @escaping (Bool) -> Void) {
        guard let email = email, let password = password else { return }
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print(error.localizedDescription)
                status(false)
            } else {
                print(result)
                self.user = result?.user
                status(true)
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            user = nil
        } catch {
            print(error)
        }
    }
}
