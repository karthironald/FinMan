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
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            FMLandingView()
                .environmentObject(hudState)
                .hud(isPresented: $hudState.isPresented, type: hudState.hudType) {
                    Label(hudState.title, systemImage: hudState.systemImage)
                        .labelStyle(CustomLabelStyle())
                }
        }
    }
}
