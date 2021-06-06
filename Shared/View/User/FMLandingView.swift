//
//  FMLandingView.swift
//  FinMan (iOS)
//
//  Created by Karthick Selvaraj on 15/05/21.
//

import SwiftUI

struct FMLandingView: View {
    
    @EnvironmentObject private var hud: FMLoadingInfoState

    @StateObject private var authenticationService = FMAuthenticationService.shared
    @State private var shouldPresentSignupForm = false
    @State private var shouldPresentLoginForm = false
    @State private var shouldPresentForgotPasswordForm = false
    
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
                        
                        .frame(width: geo.size.width - 30, height: geo.size.height * 0.5, alignment: .center)
                        Spacer()
                        FMButton(title: "Login", type: .secondary) {
                            shouldPresentLoginForm.toggle()
                        }
                        FMButton(title: "Register", type: .primary) {
                            shouldPresentSignupForm.toggle()
                        }
                        Button("Forgot Password?") {
                            shouldPresentForgotPasswordForm.toggle()
                        }
                        .padding()
                        .foregroundColor(.secondary)
                    }
                    .padding()
                }
            }
            .ignoresSafeArea(.keyboard)
            .popup(isPresented: $shouldPresentLoginForm, overlayView: {
                BottomPopupView(title: "Login", shouldDismiss: $shouldPresentLoginForm) {
                    FMSignupView(shouldPresentSignupForm: $shouldPresentLoginForm, type: .login)
                }
            })
            .popup(isPresented: $shouldPresentSignupForm, overlayView: {
                BottomPopupView(title: "Signup", shouldDismiss: $shouldPresentSignupForm) {
                    FMSignupView(shouldPresentSignupForm: $shouldPresentSignupForm, type: .signup)
                }
            })
            .popup(isPresented: $shouldPresentForgotPasswordForm, overlayView: {
                BottomPopupView(title: "Rest Password", shouldDismiss: $shouldPresentForgotPasswordForm) {
                    FMSignupView(shouldPresentSignupForm: $shouldPresentForgotPasswordForm, type: .resetPassword)
                }
            })
            .accentColor(AppSettings.appPrimaryColour)
        }
    }
}

struct FMLandingView_Previews: PreviewProvider {
    static var previews: some View {
        FMLandingView()
    }
}
