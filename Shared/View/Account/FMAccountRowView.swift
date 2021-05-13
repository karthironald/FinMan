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
    
    var body: some View {
        ZStack {
            HStack(alignment: .center, spacing: 5) {
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text(accountRowViewModel.account.name)
                            .font(.footnote)
                            .bold()
                            .foregroundColor(.secondary)
                        if let comments = accountRowViewModel.account.comments?.trimmingCharacters(in: .whitespacesAndNewlines), !comments.isEmpty, !shouldShowInfo {
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
                        Spacer()
                    }
                    HStack {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Total")
                                .font(.footnote)
                            Text("\(accountRowViewModel.total(), specifier: "%0.2f")")
                                .font(.body)
                                .bold()
                                .foregroundColor(.blue)
                        }
                        Spacer()
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Income")
                                .font(.footnote)
                            Text("\(accountRowViewModel.account.income, specifier: "%0.2f")")
                                .font(.body)
                                .bold()
                                .foregroundColor(.green)
                        }
                        Spacer()
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Expense")
                                .font(.footnote)
                            Text("\(accountRowViewModel.account.expense, specifier: "%0.2f")")
                                .font(.body)
                                .bold()
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .opacity(shouldShowInfo ? 0.1 : 1)
            .padding([.bottom], 15)
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
        .frame(maxHeight: .infinity, alignment: .center)
        .padding()
    }
}

struct FMAccountRow_Previews: PreviewProvider {
    static var previews: some View {
        FMAccountRowView(accountRowViewModel: FMAccountRowViewModel(account: FMAccount.sampleData.first!))
    }
}
