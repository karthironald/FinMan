//
//  FMTabView.swift
//  FinMan (iOS)
//
//  Created by Karthick Selvaraj on 09/04/21.
//

import SwiftUI

struct FMTabView: View {
    var body: some View {
        TabView {
            FMAccountListView()
                .tabItem {
                    Label("Accounts", systemImage: "person.2.circle.fill")
                }
            FMProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle.fill")
                }
        }
    }
}

struct FMTabView_Previews: PreviewProvider {
    static var previews: some View {
        FMTabView()
    }
}
