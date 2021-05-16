//
//  FMSignupView.swift
//  FinMan (iOS)
//
//  Created by Karthick Selvaraj on 15/05/21.
//

import SwiftUI

struct FMSignupView: View {
    
    @StateObject private var loadingHelper = FMLoadingHelper()
    @StateObject private var authService = FMAuthenticationService.shared
    
    @State private var email = ""
    @State private var password = ""
    
    @State private var emailInfoMessage = ""
    @State private var passwordInfoMessage = ""
    @State private var apiInfoMessage = ""
    
    @Binding var shouldPresentSignupForm: Bool
    
    var type: FMSignupView.FormType = .signup
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 5) {
                    FMTextField(title: "Email", keyboardType: .emailAddress, value: $email)
                    if !emailInfoMessage.isEmpty {
                        Text(emailInfoMessage)
                            .font(.footnote)
                            .foregroundColor(.red)
                    }
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    SecureField("Password", text: $password)
                        .modifier(FMTextFieldThemeModifier(keyboardType: .default))
                    if !passwordInfoMessage.isEmpty {
                        Text(passwordInfoMessage)
                            .font(.footnote)
                            .foregroundColor(.red)
                    }
                }
                
                Spacer()
                    .frame(height: 10, alignment: .center)
                VStack(alignment: .leading, spacing: 5) {
                    FMButton(title: type == .signup ? "Signup" : "Login", type: .primary) {
                        actionButtonTapped()
                    }
                    if !apiInfoMessage.isEmpty {
                        Text(apiInfoMessage)
                            .font(.footnote)
                            .foregroundColor(.red)
                    }
                }
                .padding(.bottom)
                Spacer()
            }
            .padding()
            .navigationBarTitle(type == .signup ? Text("Registration") : Text("Login"), displayMode: .inline)
            .navigationBarItems(trailing: closeButtonView())
            .startLoading(start: loadingHelper.shouldShowLoading)
        }
    }
    
    func closeButtonView() -> some View {
        Button(action: {
            shouldPresentSignupForm.toggle()
        }, label: {
            Image(systemName: "xmark.circle.fill")
                .font(.title3)
        })
        .foregroundColor(.secondary)
    }
    
    func actionButtonTapped() {
        email = email.trimmingCharacters(in: .whitespacesAndNewlines)
        password = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if email.isEmpty || !FMHelper.isValidEmail(email) {
            setInfo(message: "Please enter a valid email address", for: .email)
            return
        } else {
            setInfo(message: "", for: .email)
        }
        
        if password.isEmpty || password.count < 8 {
            setInfo(message: "Please enter a valid password with minimum 8 characters", for: .password)
            return
        } else {
            setInfo(message: "", for: .password)
        }
        
        if type == .signup {
            setInfo(message: "", for: .api)
            toggleLoadingIndicator()
            authService.signup(with: email, password: password) { _ in
                toggleLoadingIndicator()
                shouldPresentSignupForm.toggle()
            } failureBlock: { error in
                toggleLoadingIndicator()
                setInfo(message: error.localizedDescription, for: .api)
            }
        } else {
            setInfo(message: "", for: .api)
            toggleLoadingIndicator()
            authService.signin(with: email, password: password) { _ in
                toggleLoadingIndicator()
                shouldPresentSignupForm.toggle()
            } failureBlock: { error in
                print(error)
                toggleLoadingIndicator()
                setInfo(message: error.localizedDescription, for: .api)
            }
        }
    }
    
    func toggleLoadingIndicator() {
        withAnimation {
            loadingHelper.shouldShowLoading.toggle()
        }
    }
    
    func setInfo(message: String, for type: InfoMessageType) {
        switch type {
        case .email:
            withAnimation {
                emailInfoMessage = message
            }
        case .password:
            withAnimation {
                passwordInfoMessage = message
            }
        case .api:
            withAnimation {
                apiInfoMessage = message
            }
        }
    }
    
}

extension FMSignupView {
    
    enum FormType {
        case login, signup
    }
    
    enum InfoMessageType {
        case email, password, api
    }
    
}

struct FMSignupView_Previews: PreviewProvider {
    static var previews: some View {
        FMSignupView(shouldPresentSignupForm: .constant(false))
    }
}

