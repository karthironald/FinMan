//
//  FMIncomeListView.swift
//  FinMan (iOS)
//
//  Created by Karthick Selvaraj on 09/04/21.
//

import Foundation
import SwiftUI

struct FMIncomeListView: View {
    
    @StateObject var viewModel = FMIncomeViewModel()
    
    var body: some View {
        NavigationView {
            List(viewModel.incomes) { income in
                FMIncomeRow(income: income)
            }
            .frame(minWidth: 250)
            .navigationTitle("Income")
            .toolbar(content: {
                ToolbarItem {
                    Button(action: {
                        viewModel.addNew(income: FMIncome(id: UUID(), value: 100, frequency: .yearly))
                    }, label: {
                        Label("Add Income", systemImage: "plus")
                    })
                }
            })
        }
    }
    
}

struct FMContentViewiOS_Previews: PreviewProvider {
    
    static var previews: some View {
        ContentView()
    }
    
}

