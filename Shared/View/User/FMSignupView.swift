//
//  FMSignupView.swift
//  FinMan (iOS)
//
//  Created by Karthick Selvaraj on 15/05/21.
//

import SwiftUI

struct FMSignupView: View {
    
    @StateObject private var authService = FMAuthenticationService.shared
    
    @State private var email = "karthick3@gmail.com"
    @State private var password = "Password123"
    @State private var emailInfoMessage = ""
    @State private var passwordInfoMessage = ""
    
    @Binding var shouldPresentSignupForm: Bool
    
    var type: FMSignupView.FormType = .signup
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 0) {
                    FMTextField(title: "Email", keyboardType: .emailAddress, value: $email)
                    if !emailInfoMessage.isEmpty {
                        Text(emailInfoMessage)
                            .font(.footnote)
                            .foregroundColor(.red)
                    }
                }
                
                VStack(alignment: .leading, spacing: 0) {
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
                FMButton(title: type == .signup ? "Signup" : "Login", type: .primary) {
                    actionButtonTapped()
                }
                .padding(.bottom)
                Spacer()
            }
            .padding()
            .navigationBarTitle(type == .signup ? Text("New Registration") : Text("Login"), displayMode: .inline)
            .navigationBarItems(trailing: closeButtonView())
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
            withAnimation {
                emailInfoMessage = "Please enter a valid email address"
            }
            return
        } else {
            withAnimation {
                emailInfoMessage = ""
            }
        }
        
        if password.isEmpty || password.count < 8 {
            withAnimation {
                passwordInfoMessage = "Please enter a valid password with minimum 8 characters"
            }
            return
        } else {
            withAnimation {
                passwordInfoMessage = ""
            }
        }
        
        if type == .signup {
            authService.signup(with: email, password: password) { _ in
                shouldPresentSignupForm.toggle()
            }
        } else {
            authService.signin(with: email, password: password) { _ in
                shouldPresentSignupForm.toggle()
            }
        }
    }
    
}

extension FMSignupView {
    
    enum FormType {
        case login, signup
    }
    
}
struct FMSignupView_Previews: PreviewProvider {
    static var previews: some View {
        FMSignupView(shouldPresentSignupForm: .constant(false))
    }
}

