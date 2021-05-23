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
    @Namespace private var animation
    @State private var shouldShowEditAccount = false
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                HStack(alignment: .center, spacing: 5) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text(accountRowViewModel.account.name)
                                .font(.footnote)
                                .bold()
                            if let comments = accountRowViewModel.account.comments?.trimmingCharacters(in: .whitespacesAndNewlines), !comments.isEmpty, !shouldShowInfo {
                                Image(systemName: "info.circle")
                                    .resizable()
                                    .frame(width: 15, height: 15, alignment: .center)
                                    .foregroundColor(.secondary)
                                    .onTapGesture {
                                        withAnimation {
                                            shouldShowInfo.toggle()
                                        }
                                    }
                            }
                            Spacer()
                        }
                        HStack {
                            VStack(alignment: .leading, spacing: 0) {
                                Text("Income")
                                    .foregroundColor(.secondary)
                                Text("\(accountRowViewModel.account.income, specifier: "%0.2f")")
                                    .bold()
                                    .foregroundColor(.green)
                            }
                            .frame(width: geo.size.width / 3, alignment: .leading)
                            VStack(alignment: .leading, spacing: 0) {
                                Text("Expense")
                                    .foregroundColor(.secondary)
                                Text("\(accountRowViewModel.account.expense, specifier: "%0.2f")")
                                    .bold()
                                    .foregroundColor(.red)
                            }
                            .frame(width: geo.size.width / 3, alignment: .leading)
                            VStack(alignment: .leading, spacing: 0) {
                                Text("Total")
                                    .foregroundColor(.secondary)
                                Text("\(accountRowViewModel.total(), specifier: "%0.2f")")
                                    .bold()
                                    .foregroundColor(.blue)
                            }
                            .frame(width: geo.size.width / 3, alignment: .leading)
                        }
                        .font(.footnote)
                    }
                }
                .opacity(shouldShowInfo ? 0.1 : 1)
                .padding([.bottom, .top], 15)
                if let comments = accountRowViewModel.account.comments?.trimmingCharacters(in: .whitespacesAndNewlines), !comments.isEmpty, shouldShowInfo {
                    Text("(\(comments))")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .matchedGeometryEffect(id: "InfoText", in: animation)
                        .onTapGesture {
                            withAnimation {
                                shouldShowInfo.toggle()
                            }
                        }
                }
            }
            .sheet(isPresented: $shouldShowEditAccount, content: {
                FMAddAccountView(name: accountRowViewModel.account.name, comments: accountRowViewModel.account.comments ?? "", shouldPresentAddAccountView: $shouldShowEditAccount, accountRowViewModel: accountRowViewModel)
                    .accentColor(AppSettings.appPrimaryColour)
            })
        }
        .contextMenu {
            Button(action: {
                self.shouldShowEditAccount.toggle()
            }) {
                Image(systemName: "pencil.circle")
                Text("Edit Account")
            }
        }
        .frame(height: 90)
    }
}

struct FMAccountRow_Previews: PreviewProvider {
    static var previews: some View {
        FMAccountRowView(accountRowViewModel: FMAccountRowViewModel(account: FMAccount.sampleData.first!))
    }
}
