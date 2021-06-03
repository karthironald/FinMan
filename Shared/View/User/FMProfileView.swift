//
//  FMProfileView.swift
//  FinMan (iOS)
//
//  Created by Karthick Selvaraj on 15/05/21.
//

import SwiftUI

struct FMProfileView: View {
    
    @StateObject private var authService = FMAuthenticationService.shared
    
    var body: some View {
        List {
            VStack(alignment: .leading) {
                Text("Email")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                Text(authService.user?.email ?? "-")
            }
            .padding([.top, .bottom], 5)
            Section {
                Button("Logout") {
                    authService.signOut()
                }
                .foregroundColor(.red)
            }
        }
        .listStyle(InsetGroupedListStyle())
        .frame(height: 200, alignment: .center)
    }
    
}

struct FMProfileView_Previews: PreviewProvider {
    static var previews: some View {
        FMProfileView()
    }
}
