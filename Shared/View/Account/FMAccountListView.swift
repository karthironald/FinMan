//
//  FMAccountListView.swift
//  FinMan
//
//  Created by Karthick Selvaraj on 02/05/21.
//

import SwiftUI

struct FMAccountListView: View {
    
    @StateObject var viewModel = FMAccountListViewModel()
    @State private var selectedTab = 0
    @State private var shouldPresentAddAccountView = false
    @State private var shouldPresentProfileView = false
    @State private var alertInfoMessage = ""
    @State private var shouldShowAlert = false
    @State private var shouldShowEditAccount = false
    
    
    // MARK: - View Body
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                List {
                    ForEach(viewModel.accountRowViewModel, id: \.id) { accountViewModel in
                        NavigationLink(
                            destination: FMTransactionListView(accountViewModel: accountViewModel)) {
                            FMAccountRowView(accountRowViewModel: accountViewModel)
                                .contextMenu {
                                    Button(action: {
                                        viewModel.selectedAccountRowViewModel = accountViewModel
                                        self.shouldShowEditAccount.toggle()
                                    }) {
                                        Image(systemName: "pencil.circle")
                                        Text("Edit Account")
                                    }
                                }
                        }
                    }
                    .onDelete { (indexSet) in
                        if let index = indexSet.first {
                            viewModel.accountRowViewModel[index].delete { error in
                                if let error = error {
                                    alertInfoMessage = error.localizedDescription
                                    shouldShowAlert = true
                                }
                            }
                        }
                    }
                }
                .alert(isPresented: $shouldShowAlert, content: {
                    Alert(title: Text(alertInfoMessage), message: nil, dismissButton: Alert.Button.default(Text(kOkay), action: {
                        // Do nothing
                    }))
                })
                .listStyle(InsetGroupedListStyle())
                addAccountView()
            }
            .onAppear(perform: {
                FMAccountRepository.shared.selectedAccount = nil
            })
            .navigationTitle("Accounts")
            .navigationBarItems(leading: profileButtonview())
        }
        .popup(isPresented: $shouldShowEditAccount, overlayView: {
            BottomPopupView(title: "Edit Account", shouldDismiss: $shouldShowEditAccount) {
                if let selectedAccountRowViewModel = viewModel.selectedAccountRowViewModel {
                    FMAddAccountView(name: selectedAccountRowViewModel.account.name ?? "", comments: selectedAccountRowViewModel.account.fmAccountDescription ?? "", shouldPresentAddAccountView: $shouldShowEditAccount, accountRowViewModel: selectedAccountRowViewModel)
                        .accentColor(AppSettings.appPrimaryColour)
                }
            }
        })
        .popup(isPresented: $shouldPresentProfileView, overlayView: {
            BottomPopupView(title: "Profile", shouldDismiss: $shouldPresentProfileView) {
                FMProfileView()
            }
        })
        .popup(isPresented: $shouldPresentAddAccountView) {
            BottomPopupView(title: "Add Account", shouldDismiss: $shouldPresentAddAccountView) {
                FMAddAccountView(shouldPresentAddAccountView: $shouldPresentAddAccountView, viewModel: viewModel)
                    .accentColor(AppSettings.appPrimaryColour)
            }
        }
        
    }
    
    
    // MARK: - Custom methods
    
    func profileButtonview() -> some View {
        Button(action: {
            shouldPresentProfileView.toggle()
        }, label: {
            Image(systemName: "person.circle.fill")
                .font(.title)
        })
    }
    
    func addAccountView() -> some View {
        Button(action: {
            shouldPresentAddAccountView.toggle()
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

struct FMAccountListView_Previews: PreviewProvider {
    static var previews: some View {
        FMAccountListView(viewModel: FMAccountListViewModel())
    }
}
