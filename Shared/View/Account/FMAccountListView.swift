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
    
    var body: some View {
        GeometryReader { proxy in
            if viewModel.accountRowViewModel.count > 0 {
                LazyHStack {
                    TabView(selection: $selectedTab) {
                        ForEach(0..<viewModel.accountRowViewModel.count, id: \.self) { index in
                            FMAccountRowView(accountRowViewModel: viewModel.accountRowViewModel[index])
                                .tag(index)
                        }
                    }
                    .frame(width: proxy.size.width, alignment: .center)
                    .tabViewStyle(PageTabViewStyle())
                    .onChange(of: selectedTab, perform: { value in
                        FMAccountRepository.shared.selectedAccount = viewModel.accountRowViewModel[value].account
                    })
                }
            } else {
                if viewModel.isFetching {
                    Text("Loading..")
                        .multilineTextAlignment(.center)
                        .padding()
                        .frame(width: proxy.size.width, height: proxy.size.height, alignment: .center)
                } else {
                    Text("Seems, no account has been added. Add an Account to proceed further")
                        .multilineTextAlignment(.center)
                        .padding()
                        .frame(width: proxy.size.width, height: proxy.size.height, alignment: .center)
                }
            }
        }
        .background(Color.green)
        .cornerRadius(10)
    }
}

struct FMAccountListView_Previews: PreviewProvider {
    static var previews: some View {
        FMAccountListView(viewModel: FMAccountListViewModel())
    }
}
