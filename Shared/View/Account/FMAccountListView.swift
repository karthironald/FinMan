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
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                List {
                    ForEach(viewModel.accountRowViewModel, id: \.id) { accountViewModel in
                        NavigationLink(
                            destination: FMTransactionListView(accountViewModel: accountViewModel)) {
                            FMAccountRowView(accountRowViewModel: accountViewModel)
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
            .navigationTitle("Accounts")
            .navigationBarItems(trailing: profileButtonview())
        }
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
        
        #warning("We don't need menu style account selection for now")
//        Menu {
//            Picker(selection: $selectedTab, label: Text("Acc"), content: {
//                ForEach(0..<viewModel.accountRowViewModel.count, id: \.self) { index in
//                    Text(viewModel.accountRowViewModel[index].account.name)
//                        .tag(index)
//                }
//            })
//            .onChange(of: selectedTab, perform: { value in
//                FMAccountRepository.shared.selectedAccount = viewModel.accountRowViewModel[value].account
//            })
//            Section {
//                Button(action: {
//                    shouldPresentAddAccountView.toggle()
//                }, label: {
//                    Label("Add Account", systemImage: "person.crop.circle.fill.badge.plus")
//                })
//            }
//        } label: {
//            let containsAccount = (viewModel.accountRowViewModel.count > 0)
//            Label(containsAccount ? viewModel.accountRowViewModel[selectedTab].account.name : "Add Account", systemImage: containsAccount ? "person.circle.fill" : "person.crop.circle.fill.badge.plus")
//                .frame(width: 150, alignment: .trailing)
//                .onTapGesture {
//                    if containsAccount {
//                        shouldPresentAddAccountView.toggle()
//                    }
//                }
//        }
                
        
        // We are facing list deselection and hanging issue when having tab based swipable view. So went for menu based approach.
        
//        GeometryReader { proxy in
//            if viewModel.accountRowViewModel.count > 0 {
//                TabView(selection: $selectedTab) {
//                    ForEach(0..<viewModel.accountRowViewModel.count, id: \.self) { index in
//                        FMAccountRowView(accountRowViewModel: viewModel.accountRowViewModel[index])
//                            .tag(index)
//                    }
//                }
//                .onAppear(perform: {
//                    UIScrollView.appearance().bounces = false // To restrict the vertical scroll of the tabView
//                })
//                .frame(width: proxy.size.width, height: 115, alignment: .center) // Provided height to adjust the paging indicator position
//                .tabViewStyle(PageTabViewStyle())
//                .onChange(of: selectedTab, perform: { value in
//                    FMAccountRepository.shared.selectedAccount = viewModel.accountRowViewModel[value].account
//                })
//            } else {
//                Text(viewModel.isFetching ? "Loading..." : "Seems, no account has been added. Add an Account to proceed further")
//                    .multilineTextAlignment(.center)
//                    .padding()
//                    .frame(width: proxy.size.width, height: proxy.size.height, alignment: .center)
//            }
//        }
//        .background(Color.secondary.opacity(0.3))
//        .cornerRadius(20)
        
    }
    
    func profileButtonview() -> some View {
        Button(action: {
            shouldPresentProfileView.toggle()
        }, label: {
            Image(systemName: "person.circle.fill")
                .font(.title2)
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
