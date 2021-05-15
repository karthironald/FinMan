//
//  FMProfileView.swift
//  FinMan (iOS)
//
//  Created by Karthick Selvaraj on 15/05/21.
//

import SwiftUI

struct FMProfileView: View {
    
    @StateObject var authService = FMAuthenticationService.shared
    
    var body: some View {
        NavigationView {
            List {
                VStack(alignment: .leading) {
                    Text("Email")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    Text(authService.user?.email ?? "-")
                }
                VStack(alignment: .leading) {
                    Text("Anonymous")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    Text((authService.user?.isAnonymous == true) ? "Yes" : "No")
                }
                VStack(alignment: .leading) {
                    Text("Email Verification Status")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    Text((authService.user?.isEmailVerified == true) ? "Verified" : "Not Verified")
                }
                Section {
                    Button("Logout") {
                        authService.signOut()
                    }
                    .foregroundColor(.red)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Profile")
        }
    }
    
}

struct FMProfileView_Previews: PreviewProvider {
    static var previews: some View {
        FMProfileView()
    }
}
