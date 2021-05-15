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
                        .frame(width: geo.size.width - 30, height: geo.size.height * 0.7, alignment: .center)
                        .background(AppSettings.appSecondaryColour)
                        .cornerRadius(AppSettings.appCornerRadius)
                        Spacer()
                        FMButton(title: "Login", type: .secondary) {
                            shouldPresentLoginForm.toggle()
                        }
                        FMButton(title: "Register", type: .primary) {
                            shouldPresentSignupForm.toggle()
                        }
                        
                    }
                    .padding()
                }
                .sheet(isPresented: $shouldPresentLoginForm, content: {
                    FMSignupView(shouldPresentSignupForm: $shouldPresentLoginForm, type: .login)
                })
            }
            .accentColor(AppSettings.appPrimaryColour)
            .sheet(isPresented: $shouldPresentSignupForm, content: {
                FMSignupView(shouldPresentSignupForm: $shouldPresentSignupForm, type: .signup)
            })
        }
    }
}

struct FMLandingView_Previews: PreviewProvider {
    static var previews: some View {
        FMLandingView()
    }
}
