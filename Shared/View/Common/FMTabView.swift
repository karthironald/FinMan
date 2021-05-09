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
            FMTransactionListView()
                .tabItem {
                    Label("Dashboard", systemImage: "dollarsign.circle")
                }
        }
    }
}

struct FMTabView_Previews: PreviewProvider {
    static var previews: some View {
        FMTabView()
    }
}
