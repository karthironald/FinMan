//
//  FMLandingView.swift
//  FinMan (iOS)
//
//  Created by Karthick Selvaraj on 15/05/21.
//

import SwiftUI

struct FMLandingView: View {
    
    @StateObject private var authenticationService = FMAuthenticationService.shared
    @State private var shouldPresentSignupForm = false
    @State private var shouldPresentLoginForm = false
    
    var body: some View {
        if authenticationService.user != nil {
            FMTabView()
                .accentColor(AppSettings.appPrimaryColour)
        } else {
            GeometryReader { geo in
                ZStack {
                    VStack(spacing: 25) {
                        VStack {
                            Image(systemName: "dollarsign.circle.fill")
                                .resizable()
                                .frame(width: 100, height: 100, alignment: .center)
                                .padding()
                                .foregroundColor(AppSettings.appPrimaryColour)
                                
                            Text("Hi, Welcome!")
                                .font(.title)
                                .bold()
                            Text("Click Login if you have account already, else click Register to create new account")
                                .font(.body)
                                .bold()
                                .foregroundColor(.secondary)
                                .padding()
                                .multilineTextAlignment(.center)
                        }
                        
                        .frame(width: geo.size.width - 30, height: geo.size.height * 0.6, alignment: .center)
                        Spacer()
                        FMButton(title: "Login", type: .secondary) {
                            shouldPresentLoginForm.toggle()
                        }
                        .sheet(isPresented: $shouldPresentLoginForm, content: {
                            FMSignupView(shouldPresentSignupForm: $shouldPresentLoginForm, type: .login)
                        })
                        FMButton(title: "Register", type: .primary) {
                            shouldPresentSignupForm.toggle()
                        }
                        .sheet(isPresented: $shouldPresentSignupForm, content: {
                            FMSignupView(shouldPresentSignupForm: $shouldPresentSignupForm, type: .signup)
                        })
                    }
                    
                    .padding()
                }
            }
            .accentColor(AppSettings.appPrimaryColour)
            
        }
    }
}

struct FMLandingView_Previews: PreviewProvider {
    static var previews: some View {
        FMLandingView()
    }
}
