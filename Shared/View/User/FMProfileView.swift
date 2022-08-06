//
//  FMProfileView.swift
//  FinMan (iOS)
//
//  Created by Karthick Selvaraj on 15/05/21.
//

import SwiftUI

struct FMProfileView: View {
    
    @EnvironmentObject var loadingInfoState: FMLoadingInfoState
    @StateObject private var authService = FMAuthenticationService.shared
    
    
    // MARK: - View Body
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: AppSettings.vStackSpacing) {
                viewFor(title: "Email", and: authService.user?.email ?? "-")
//                viewFor(title: "Email verified", and: (authService.user?.isEmailVerified == true) ? "Yes" : "No")
//                if let createdAt = authService.user?.metadata.creationDate {
//
//                    VStack(alignment: .leading, spacing: 5) {
//                        Text("Account created on")
//                            .font(.footnote)
//                            .foregroundColor(.secondary)
//                        Text("\(createdAt, style: .date) \(createdAt, style: .time)")
//                    }
//                }
//                if let lastSignInDate = authService.user?.metadata.lastSignInDate {
//                    VStack(alignment: .leading, spacing: 5) {
//                        Text("Last signed in")
//                            .font(.footnote)
//                            .foregroundColor(.secondary)
//                        Text("\(lastSignInDate, style: .date) \(lastSignInDate, style: .time)")
//                    }
//                }
                FMButton(title: "Logout", type: .logout, shouldShowLoading: loadingInfoState.shouldShowLoading) {
                    loadingInfoState.startLoading()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        authService.signOut()
                        loadingInfoState.stopLoading()
                    }
                }
            }
            Spacer()
        }
        .padding([.horizontal, .bottom])
    }
 
    
    // MARK: - Custom methods
    
    func viewFor(title: String, and value: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.footnote)
                .foregroundColor(.secondary)
            Text(value)
        }
    }
    
}

struct FMProfileView_Previews: PreviewProvider {
    static var previews: some View {
        FMProfileView()
    }
}
