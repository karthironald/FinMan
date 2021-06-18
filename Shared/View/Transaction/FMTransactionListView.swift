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
    
    @State var shouldPresentAddTransactionView: Bool = false
    @State var shouldPresentAddAccountView: Bool = false
    @State private var alertInfoMessage = ""
    @State private var shouldShowAlert = false
    @ObservedObject var accountViewModel: FMAccountRowViewModel
    @State private var selectedTimePeriod = FMTimePeriod.all
    
    var body: some View {
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
                        Button(viewModel.isFetching ? "Loading..." : "Load More...") {
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
            addTransactionView()
        }
        .navigationBarItems(trailing: filterMenu())
        .onAppear(perform: {
            if FMAccountRepository.shared.selectedAccount?.id != accountViewModel.account.id {            
                FMAccountRepository.shared.selectedAccount = accountViewModel.account
            }
        })
        .navigationBarTitle("\(accountViewModel.account.name.capitalized)", displayMode: .inline)
        .popup(isPresented: $shouldPresentAddTransactionView, overlayView: {
            BottomPopupView(title: "Add Transaction", shouldDismiss: $shouldPresentAddTransactionView) {
                FMAddTransactionView(viewModel: viewModel, shouldPresentAddTransactionView: $shouldPresentAddTransactionView)
                    .accentColor(AppSettings.appPrimaryColour)
            }
        })
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
    
    func filterMenu() -> some View {
        Menu {
            ForEach(0..<FMTimePeriod.allCases.count, id: \.self) { index in
                Button("\(FMTimePeriod.allCases[index].title())") {
                    selectedTimePeriod = FMTimePeriod.allCases[index]
                    viewModel.fetchTransaction(for: selectedTimePeriod)
                }
            }
        } label: {
            Text(selectedTimePeriod.title())
                .frame(width: 100, height: 30, alignment: .trailing)
        }
    }
    
}

struct FMTransactionListView_Previews: PreviewProvider {
    
    static var previews: some View {
        let viewModel = FMTransactionListViewModel()
        let rowViewModel = FMTransactionRowViewModel(transaction: FMTransaction.sampleData.first!)
        viewModel.transactionRowViewModel = [rowViewModel]
        return FMTransactionListView(viewModel: viewModel, shouldPresentAddTransactionView: false, accountViewModel: FMAccountRowViewModel(account: FMAccount.sampleData.first!))
    }
    
}

