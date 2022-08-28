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
            FMTransactionListView().tabItem {
                Label("Transaction", systemImage: "building.columns")
            }
            FMInvestmentPlanView().tabItem {
                Label("Budget", systemImage: "bag.circle.fill")
            }
        }
    }
    
}

struct FMTabView_Previews: PreviewProvider {
    static var previews: some View {
        FMTabView()
    }
}
