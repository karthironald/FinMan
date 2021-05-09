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
                TabView(selection: $selectedTab) {
                    ForEach(0..<viewModel.accountRowViewModel.count, id: \.self) { index in
                        FMAccountRowView(accountRowViewModel: viewModel.accountRowViewModel[index])
                            .tag(index)
                    }
                }
                .onAppear(perform: {
                    UIScrollView.appearance().bounces = false // To restrict the vertical scroll of the tabView
                })
                .frame(width: proxy.size.width, height: 115, alignment: .center) // Provided height to adjust the paging indicator position
                .tabViewStyle(PageTabViewStyle())
                .onChange(of: selectedTab, perform: { value in
                    FMAccountRepository.shared.selectedAccount = viewModel.accountRowViewModel[value].account
                })
            } else {
                Text(viewModel.isFetching ? "Loading..." : "Seems, no account has been added. Add an Account to proceed further")
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(width: proxy.size.width, height: proxy.size.height, alignment: .center)
            }
        }
        .background(Color.secondary.opacity(0.3))
        .cornerRadius(20)
    }
}

struct FMAccountListView_Previews: PreviewProvider {
    static var previews: some View {
        FMAccountListView(viewModel: FMAccountListViewModel())
    }
}
