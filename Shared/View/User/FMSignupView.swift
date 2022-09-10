//
//  FMSignupView.swift
//  FinMan (iOS)
//
//  Created by Karthick Selvaraj on 15/05/21.
//

import SwiftUI
import Alamofire

struct FMSignupView: View {
    
    @EnvironmentObject private var hud: FMLoadingInfoState
    @StateObject private var authService = FMAuthenticationService.shared
    
#if DEBUG
    @State private var email = "test1"
    @State private var password = "Password123@"
#else
    @State private var email = ""
    @State private var password = ""
#endif
    
    @State private var emailInfoMessage = ""
    @State private var passwordInfoMessage = ""
    @State private var apiInfoMessage = ""
    
    @Binding var shouldPresentSignupForm: Bool
    
    var type: FMSignupView.FormType = .signup
    
    
    // MARK: - View Body
    
    var body: some View {
        VStack(spacing: AppSettings.vStackSpacing) {
            VStack(alignment: .leading, spacing: 5) {
                FMTextField(title: "Email", keyboardType: .emailAddress, value: $email, infoMessage: $emailInfoMessage)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
            }
            
            if (type == .login || type == .signup) {
                VStack(alignment: .leading, spacing: 5) {
                    SecureField("Password", text: $password)
                        .modifier(FMTextFieldThemeModifier(keyboardType: .default))
                    if !passwordInfoMessage.isEmpty {
                        Text(passwordInfoMessage)
                            .font(.footnote)
                            .foregroundColor(.red)
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 5) {
                FMButton(title: type.actionButtonTitle, type: .primary, shouldShowLoading: hud.shouldShowLoading) {
                    actionButtonTapped()
                }
                if !apiInfoMessage.isEmpty {
                    Text(apiInfoMessage)
                        .font(.footnote)
                        .foregroundColor(.red)
                }
            }
            .padding(.top)
        }
        .padding([.horizontal, .bottom]) // We are not setting `top` padding as we have padding in the BottomPopup title's bottom.
    }
    
    
    // MARK: - Custom methods
    
    func actionButtonTapped() {
        email = email.trimmingCharacters(in: .whitespacesAndNewlines)
        password = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if email.isEmpty {
            setInfo(message: "Please enter a valid email address", for: .email)
            return
        } else {
            setInfo(message: "", for: .email)
        }
        if (type == .login || type == .signup) {
            if password.isEmpty || password.count < 8 {
                setInfo(message: "Please enter a valid password with minimum 8 characters", for: .password)
                return
            } else {
                setInfo(message: "", for: .password)
            }
        }
        
        switch type {
        case .login:
            setInfo(message: "", for: .api)
            startLoadingIndicator()
            authService.signin(with: email, password: password) { _ in
                stopLoadingIndicator()
                shouldPresentSignupForm.toggle()
            } failureBlock: { error in
                stopLoadingIndicator()
                setInfo(message: error?.localizedDescription ?? kCommonErrorMessage, for: .api)
            }
        case .signup:
            setInfo(message: "", for: .api)
            startLoadingIndicator()
            authService.signup(with: email, password: password) { _ in
                stopLoadingIndicator()
                shouldPresentSignupForm.toggle()
            } failureBlock: { error in
                stopLoadingIndicator()
                setInfo(message: error?.localizedDescription ?? kCommonErrorMessage, for: .api)
            }
        case .resetPassword:
            startLoadingIndicator()
            authService.initiateRestPassword(for: email) { _ in
                stopLoadingIndicator()
                hud.show(title: "Please check your email inbox for password reset instructions", type: .info)
            } failureBlock: { error in
                stopLoadingIndicator()
                setInfo(message: error?.localizedDescription ?? kCommonErrorMessage, for: .api)
            }
        }
    }
    
    func startLoadingIndicator() {
        withAnimation {
            hud.startLoading()
        }
    }
    
    func stopLoadingIndicator() {
        withAnimation {
            hud.stopLoading()
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
        case login, signup, resetPassword
        
        var screenTitle: String {
            switch self {
            case .login: return "Login"
            case .signup: return "Registration"
            case .resetPassword: return "Reset Password"
            }
        }
        
        var actionButtonTitle: String {
            switch self {
            case .login: return "Login"
            case .signup: return "Signup"
            case .resetPassword: return "Submit"
            }
        }
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

