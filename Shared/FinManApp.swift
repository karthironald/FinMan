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
    
    @StateObject var hudState = FMLoadingInfoState()
    @StateObject var currentUser = FMCurrentUser()
    
    // MARK: - Init Methods
    
    init() {
        FirebaseApp.configure()
        
    }
    
    // MARK: - View Body
    
    var body: some Scene {
        WindowGroup {
            FMLandingView()
                .environmentObject(hudState)
                .environmentObject(currentUser)
                .hud(isPresented: $hudState.isPresented, type: hudState.hudType) {
                    Label(hudState.title, systemImage: hudState.systemImage)
                        .labelStyle(CustomLabelStyle())
                }
        }
    }
}

final class FMCurrentUser: ObservableObject {
    @Published var isUserLoggedIn = false
    
    init() {
        isUserLoggedIn = (MTKeychainManager.sharedInstance.value(for: .accessToken) != nil)
    }
    
}
