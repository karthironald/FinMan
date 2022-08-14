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
    
    
    // MARK: - View Body
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                HStack(alignment: .center, spacing: 5) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text(accountRowViewModel.account.name ?? "-")
                                .font(.footnote)
                                .bold()
                            if let comments = accountRowViewModel.account.accountDescription?.trimmingCharacters(in: .whitespacesAndNewlines), !comments.isEmpty, !shouldShowInfo {
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
                                Text("\(accountRowViewModel.account.totalIncome ?? 0.0, specifier: "%0.2f")")
                                    .bold()
                                    .foregroundColor(.green)
                            }
                            .frame(width: geo.size.width / 3, alignment: .leading)
                            VStack(alignment: .leading, spacing: 0) {
                                Text("Expense")
                                    .foregroundColor(.secondary)
                                Text("\(accountRowViewModel.account.totalExpense ?? 0.0, specifier: "%0.2f")")
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
                .padding([.bottom, .top], 10)
                if let comments = accountRowViewModel.account.accountDescription?.trimmingCharacters(in: .whitespacesAndNewlines), !comments.isEmpty, shouldShowInfo {
                    Text("(\(comments))")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .matchedGeometryEffect(id: "InfoText", in: animation, properties: .size)
                        .padding()
                        .onTapGesture {
                            withAnimation {
                                shouldShowInfo.toggle()
                            }
                        }
                }
            }
        }
        .frame(height: 80)
    }
    
}

struct FMAccountRow_Previews: PreviewProvider {
    static var previews: some View {
        FMAccountRowView(accountRowViewModel: FMAccountRowViewModel(account: FMAccount.sampleData.first!))
    }
}
