//
//  FMAccountListView.swift
//  FinMan
//
//  Created by Karthick Selvaraj on 02/05/21.
//

import SwiftUI

struct FMAccountListView: View {
    
    @StateObject var viewModel = FMAccountListViewModel()
    
    var body: some View {
        GeometryReader { proxy in
            LazyHStack {
                TabView {
                    ForEach(viewModel.accountRowViewModel, id: \.id) { accountRowViewModel in
                        FMAccountRow(accountRowViewModel: accountRowViewModel)
                    }
                }
                .frame(width: proxy.size.width, alignment: .center)
                .tabViewStyle(PageTabViewStyle())
            }
        }
        .background(Color.pink)
        .cornerRadius(10)
    }
}

struct FMAccountListView_Previews: PreviewProvider {
    static var previews: some View {
        FMAccountListView(viewModel: FMAccountListViewModel())
    }
}
