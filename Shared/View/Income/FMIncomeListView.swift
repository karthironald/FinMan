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
    @State var shouldPresentAddIncomeView: Bool = false
    
    var body: some View {
        NavigationView {
            List(viewModel.incomes) { income in
                FMIncomeRow(income: income)
            }
            .frame(minWidth: 250)
            .navigationTitle("Income")
            .listStyle(InsetGroupedListStyle())
            .toolbar(content: {
                ToolbarItem {
                    Button(action: {
                        shouldPresentAddIncomeView.toggle()
                    }, label: {
                        Label("Add Income", systemImage: "plus")
                    })
                }
            })
            .sheet(isPresented: $shouldPresentAddIncomeView, content: {
                FMAddIncomeview(viewModel: viewModel, shouldPresentAddIncomeView: $shouldPresentAddIncomeView)
            })
        }
    }
    
}

struct FMContentViewiOS_Previews: PreviewProvider {
    
    static var previews: some View {
        ContentView()
    }
    
}

