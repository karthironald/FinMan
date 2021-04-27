//
//  FinManApp.swift
//  Shared
//
//  Created by Karthick Selvaraj on 06/04/21.
//

import SwiftUI
import Firebase

@main
struct FinManApp: App {
    
    init() {
        FirebaseApp.configure()
        FMAuthenticationService.shared.signIn()
    }
    
    var body: some Scene {
        WindowGroup {
            FMTabView()
        }
    }
}
