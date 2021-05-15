//
//  FMSignupView.swift
//  FinMan (iOS)
//
//  Created by Karthick Selvaraj on 15/05/21.
//

import SwiftUI

struct FMSignupView: View {
    
    @StateObject private var authService = FMAuthenticationService.shared
    
    @State private var email = ""
    @State private var password = ""
    @Binding var shouldPresentSignupForm: Bool
    
    var body: some View {
        VStack {
            
            TextField("Email", text: $email)
                .font(.body)
                .padding()
                .frame(height: 50, alignment: .center)
                .background(AppSettings.appSecondaryColour)
                .cornerRadius(AppSettings.appCornerRadius)
            
            TextField("Password", text: $password)
                .font(.body)
                .padding()
                .frame(height: 50, alignment: .center)
                .background(AppSettings.appSecondaryColour)
                .cornerRadius(AppSettings.appCornerRadius)

            Spacer()
                .frame(height: 50, alignment: .center)
            FMButton(title: "Signup", type: .primary) {
                authService.signup(with: email, password: password) { _ in
                    shouldPresentSignupForm.toggle()
                }
            }
            Spacer()
        }
        .padding()
        .background(Color.green)
    }
}

struct FMSignupView_Previews: PreviewProvider {
    static var previews: some View {
        FMSignupView(shouldPresentSignupForm: .constant(false))
    }
}

