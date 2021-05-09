//
//  FMAccountRow.swift
//  FinMan
//
//  Created by Karthick Selvaraj on 02/05/21.
//

import SwiftUI

struct FMAccountRowView: View {
    
    @ObservedObject var accountRowViewModel: FMAccountRowViewModel
    @State private var shouldShowInfo = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .center, spacing: 5) {
                Text(accountRowViewModel.account.name)
                    .font(.footnote)
                    .bold()
                    .foregroundColor(.secondary)
                HStack(spacing: 10) {
                    Spacer()
                    VStack {
                        Text("Income")
                            .font(.footnote)
                        Text("\(accountRowViewModel.account.income, specifier: "%0.2f")")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.green)
                    }
                    Spacer()
                    VStack {
                        Text("Expense")
                            .font(.footnote)
                        Text("\(accountRowViewModel.account.expense, specifier: "%0.2f")")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.red)
                    }
                    Spacer()
                }
            }
            .opacity(shouldShowInfo ? 0.1 : 1)
            if let comments = accountRowViewModel.account.comments {
                Text(comments)
                    .font(.footnote)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .opacity(shouldShowInfo ? 1 : 0.0)
            }
            Button(action: {
                withAnimation {
                    shouldShowInfo.toggle()
                }
            }, label: {
                Image(systemName: shouldShowInfo ? "xmark.circle" : "info.circle" )
                    .resizable()
                    .frame(width: 20, height: 20, alignment: .center)
            })
            .foregroundColor(.secondary)
            .opacity(0.8)
        }
        .frame(maxHeight: .infinity, alignment: .center)
        .padding()
    }
}

struct FMAccountRow_Previews: PreviewProvider {
    static var previews: some View {
        FMAccountRowView(accountRowViewModel: FMAccountRowViewModel(account: FMAccount.sampleData.first!))
    }
}
