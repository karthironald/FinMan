//
//  FMIncomeListView.swift
//  FinMan (iOS)
//
//  Created by Karthick Selvaraj on 09/04/21.
//

import Foundation
import SwiftUI

struct FMIncomeListView: View {
    
    @StateObject var viewModel = FMIncomeListViewModel()
    @State var shouldPresentAddIncomeView: Bool = false
    
    var body: some View {
        NavigationView {
            List {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.clear)
                    .frame(height: 100, alignment: .center)
                    .overlay(
                        VStack {
                            Text("Total Income")
                                .foregroundColor(.secondary)
                            Text("\(viewModel.totalIncome(), specifier: "%0.2f")")
                                .font(.largeTitle)
                                .foregroundColor(.primary)
                        }
                    )
                ForEach(viewModel.incomes) { income in
                    NavigationLink(
                        destination: FMIncomeDetail(income: income, viewModel: viewModel),
                        label: { FMIncomeRow(income: income) }
                    )
                }
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
                FMAddIncomeview(shouldPresentAddIncomeView: $shouldPresentAddIncomeView).environmentObject(viewModel)
            })
        }
    }
    
}

struct FMContentViewiOS_Previews: PreviewProvider {
    
    static var previews: some View {
        ContentView()
    }
    
}

