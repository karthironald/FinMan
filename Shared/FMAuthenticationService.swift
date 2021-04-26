//
//  FMAuthenticationService.swift
//  FinMan
//
//  Created by Karthick Selvaraj on 26/04/21.
//
import Foundation
import Firebase

class FMAuthenticationService: ObservableObject {
    
    @Published var user: User?
    private var authStateDidChangeHandler: AuthStateDidChangeListenerHandle?
    
    // MARK: - Init Methods
    
    init() {
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
    
    func signIn() {
        if Auth.auth().currentUser == nil {
            Auth.auth().signInAnonymously()
        }
    }
    
}
