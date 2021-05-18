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
    @State private var alertInfoMessage = ""
    @State private var shouldShowAlert = false
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                VStack(spacing: 0) {
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
                                        viewModel.transactionRowViewModel[index].delete(resultBlock: { error in
                                            if let error = error {
                                                alertInfoMessage = error.localizedDescription
                                                shouldShowAlert = true
                                            }
                                        })
                                    }
                                }
                            }
                        }
                        Section {
                            Button("Load More...") {
                                viewModel.fetchNextBadge()
                            }
                            .disabled(!viewModel.shouldEnableLoadMore())
                            
                        }
                    }
                    .alert(isPresented: $shouldShowAlert, content: {
                        Alert(title: Text(alertInfoMessage), message: nil, dismissButton: Alert.Button.default(Text(kOkay), action: {
                            // Do nothing
                        }))
                    })
                    .padding(0)
                    .frame(minWidth: 250)
                    .listStyle(InsetGroupedListStyle())
                }
                .startLoading(start: FMLoadingHelper.shared.shouldShowLoading)
                addTransactionView()
            }
            .navigationTitle("Dashboard")
            .navigationBarItems(trailing: accountsView())
            .sheet(isPresented: $shouldPresentAddTransactionView, content: {
                FMAddTransactionView(viewModel: viewModel, shouldPresentAddTransactionView: $shouldPresentAddTransactionView)
                    .accentColor(AppSettings.appPrimaryColour)
            })
        }
    }
    
    func accountsView() -> some View {
        FMAccountListView(viewModel: accountViewModel)
    }
    
    func addTransactionView() -> some View {
        Button(action: {
            shouldPresentAddTransactionView.toggle()
        }, label: {
            Image(systemName: "plus.circle.fill")
                .resizable()
        })
        .foregroundColor(AppSettings.appPrimaryColour)
        .frame(width: 44, height: 44)
        .background(Color.white)
        .clipShape(Circle())
        .padding()
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

