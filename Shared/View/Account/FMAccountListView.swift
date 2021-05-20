//
//  FMAccountListView.swift
//  FinMan
//
//  Created by Karthick Selvaraj on 02/05/21.
//

import SwiftUI

struct FMAccountListView: View {
    
    @ObservedObject var viewModel: FMAccountListViewModel
    @State private var selectedTab = 0
    @State private var shouldPresentAddAccountView = false
    
    var body: some View {
        Menu {
            Picker(selection: $selectedTab, label: Text("Acc"), content: {
                ForEach(0..<viewModel.accountRowViewModel.count, id: \.self) { index in
                    Text(viewModel.accountRowViewModel[index].account.name)
                        .tag(index)
                }
            })
            .onChange(of: selectedTab, perform: { value in
                FMAccountRepository.shared.selectedAccount = viewModel.accountRowViewModel[value].account
            })
            Section {
                Button(action: {
                    shouldPresentAddAccountView.toggle()
                }, label: {
                    Label("Add Account", systemImage: "person.crop.circle.fill.badge.plus")
                })
            }
        } label: {
            let containsAccount = (viewModel.accountRowViewModel.count > 0)
            Label(containsAccount ? viewModel.accountRowViewModel[selectedTab].account.name : "Add Account", systemImage: containsAccount ? "person.circle.fill" : "person.crop.circle.fill.badge.plus")
                .frame(width: 150, alignment: .trailing)
                .onTapGesture {
                    if containsAccount {
                        shouldPresentAddAccountView.toggle()
                    }
                }
        }
        .sheet(isPresented: $shouldPresentAddAccountView, content: {
            FMAddAccountView(shouldPresentAddAccountView: $shouldPresentAddAccountView, viewModel: viewModel)
                .accentColor(AppSettings.appPrimaryColour)
        })
                
        
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
}

struct FMAccountListView_Previews: PreviewProvider {
    static var previews: some View {
        FMAccountListView(viewModel: FMAccountListViewModel())
    }
}
