//
//  FMTransactionListView.swift
//  FinMan (iOS)
//
//  Created by Karthick Selvaraj on 09/04/21.
//

import Foundation
import SwiftUI

struct FMTransactionListView: View {
    
    @StateObject var viewModel = FMTransactionListViewModel()
    @StateObject var accountViewModel = FMAccountListViewModel()
    
    @State var shouldPresentAddTransactionView: Bool = false
    @State var shouldPresentAddAccountView: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                FMAccountListView(viewModel: accountViewModel)
                    .frame(height: 100, alignment: .center)
                    .padding()
                List {
                    ForEach(Array(viewModel.groupedTransactionRowViewModel.keys.sorted(by: >)), id: \.self) { (key) in
                        Section(header: Text("\(key) (\(viewModel.groupedTransactionRowViewModel[key]!.count))")) {
                            ForEach(viewModel.groupedTransactionRowViewModel[key]!, id: \.id) { transactionRowViewModel in
                                NavigationLink(
                                    destination: FMTransactionDetailView(transactionRowViewModel: transactionRowViewModel),
                                    label: {
                                        FMTransactionRowView(transactionRowViewModel: transactionRowViewModel)
                                    }
                                )
                            }
                            .onDelete { (indexSet) in
                                if let index = indexSet.first {
                                    viewModel.transactionRowViewModel[index].delete()
                                }
                            }
                        }
                    }
                    Button("Load More...") {
                        viewModel.fetchNextBadge()
                    }
                    .disabled(!viewModel.shouldEnableLoadMore())
                }
                .padding(0)
                .frame(minWidth: 250)
                .listStyle(InsetGroupedListStyle())
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
                        shouldPresentAddTransactionView.toggle()
                    }, label: {
                        Label("Add Transaction", systemImage: "bag.badge.plus")
                    })
                } label: {
                    Image(systemName: "plus")
                        .font(.title)
                }
                .sheet(isPresented: $shouldPresentAddAccountView, content: {
                    FMAddAccountView(shouldPresentAddAccountView: $shouldPresentAddAccountView, viewModel: accountViewModel)
                })
            })
            .sheet(isPresented: $shouldPresentAddTransactionView, content: {
                FMAddTransactionView(viewModel: viewModel, shouldPresentAddTransactionView: $shouldPresentAddTransactionView)
            })
        }
    }
    
}

struct FMTransactionListView_Previews: PreviewProvider {
    
    static var previews: some View {
        let viewModel = FMTransactionListViewModel()
        let rowViewModel = FMTransactionRowViewModel(transaction: FMTransaction.sampleData.first!)
        viewModel.transactionRowViewModel = [rowViewModel]
        return FMTransactionListView(viewModel: viewModel, shouldPresentAddTransactionView: false)
    }
    
}

