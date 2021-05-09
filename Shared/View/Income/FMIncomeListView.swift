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
    @StateObject var accountViewModel = FMAccountListViewModel()
    
    @State var shouldPresentAddIncomeView: Bool = false
    @State var shouldPresentAddAccountView: Bool = false
    @State var shouldPresentAddExpenseView: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                FMAccountListView(viewModel: accountViewModel)
                    .frame(height: 100, alignment: .center)
                    .padding()
                List {
                    ForEach(Array(viewModel.groupedIncomeRowViewModel.keys.sorted(by: >)), id: \.self) { (key) in
                        Section(header: Text("\(key) (\(viewModel.groupedIncomeRowViewModel[key]!.count))")) {
                            ForEach(viewModel.groupedIncomeRowViewModel[key]!, id: \.id) { incomeRowViewModel in
                                NavigationLink(
                                    destination: FMIncomeDetail(incomeRowViewModel: incomeRowViewModel),
                                    label: {
                                        FMIncomeRow(incomeRowViewModel: incomeRowViewModel)
                                            .onAppear {
                                                if incomeRowViewModel == viewModel.incomeRowViewModel.last {
                                                    viewModel.fetchNextBadge()
                                                }
                                            }
                                    }
                                )
                            }
                            .onDelete { (indexSet) in
                                if let index = indexSet.first {
                                    viewModel.incomeRowViewModel[index].delete()
                                }
                            }
                        }
                    }
                }
                .padding(0)
                .frame(minWidth: 250)
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Dashboard")
            .toolbar(content: {
                Menu {
                    Button(action: {
                        shouldPresentAddAccountView.toggle()
                    }, label: {
                        Label("Add Account", systemImage: "person.badge.plus")
                    })
                    Button(action: {
                        shouldPresentAddIncomeView.toggle()
                    }, label: {
                        Label("Add Income", systemImage: "bag.badge.plus")
                    })
                    Button(action: {
                        shouldPresentAddExpenseView.toggle()
                    }, label: {
                        Label("Add Expense", systemImage: "cart.badge.minus")
                    })
                } label: {
                    Image(systemName: "plus")
                        .font(.title)
                }
                .sheet(isPresented: $shouldPresentAddAccountView, content: {
                    FMAddAccountView(shouldPresentAddAccountView: $shouldPresentAddAccountView, viewModel: accountViewModel)
                })
            })
            .sheet(isPresented: $shouldPresentAddIncomeView, content: {
                FMAddIncomeview(viewModel: viewModel, shouldPresentAddIncomeView: $shouldPresentAddIncomeView)
            })
        }
    }
    
}

struct FMIncomeListView_Previews: PreviewProvider {
    
    static var previews: some View {
        let viewModel = FMIncomeListViewModel()
        let rowViewModel = FMIncomeRowViewModel(income: FMIncome.sampleData.first!)
        viewModel.incomeRowViewModel = [rowViewModel]
        return FMIncomeListView(viewModel: viewModel, shouldPresentAddIncomeView: false)
    }
    
}

