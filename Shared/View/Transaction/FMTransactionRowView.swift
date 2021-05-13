//
//  FMTransactionRowView.swift
//  FinMan (iOS)
//
//  Created by Karthick Selvaraj on 09/04/21.
//

import SwiftUI

struct FMTransactionRowView: View {
    
    @ObservedObject var transactionRowViewModel: FMTransactionRowViewModel
    
    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: "\(transactionRowViewModel.imageName()).square.fill")
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundColor(.secondary)
                .opacity(0.5)
            VStack(alignment: .leading) {
                Text("\(transactionRowViewModel.transaction.value, specifier: "%0.2f")")
                    .font(.body)
                    .bold()
                    .foregroundColor((transactionRowViewModel.transaction.transactionType == FMTransaction.TransactionType.income.rawValue) ? .green : .red)
                Text("\(transactionRowViewModel.transaction.transactionDate?.dateValue() ?? Date(), style: .time)")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            Spacer()
            if let freqency = transactionRowViewModel.transaction.source {
                Text("\(FMTransaction.IncomeSource(rawValue: freqency)?.title ?? "")")
                    .font(.footnote)
                    .foregroundColor(.green)
                    .padding(7)
                    .background(Color.green.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            } else if let expenseCategory = transactionRowViewModel.transaction.expenseCategory {
                Text("\(FMTransaction.ExpenseCategory(rawValue: expenseCategory)?.rawValue.capitalized ?? "")")
                    .font(.footnote)
                    .foregroundColor(.red)
                    .padding(5)
                    .background(Color.red.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }
}

struct FMTransactionRow_Previews: PreviewProvider {
    static var previews: some View {
        FMTransactionRowView(transactionRowViewModel: FMTransactionRowViewModel(transaction: FMTransaction.sampleData.first!))
    }
}
