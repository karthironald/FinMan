//
//  FMTransactionRowView.swift
//  FinMan (iOS)
//
//  Created by Karthick Selvaraj on 09/04/21.
//

import SwiftUI

struct FMTransactionRowView: View {
    
    @ObservedObject var transactionRowViewModel: FMTransactionRowViewModel
    
    
    // MARK: - View Body
    
    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: "\(transactionRowViewModel.imageName()).square.fill")
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundColor(.secondary)
                .opacity(0.5)
            VStack(alignment: .leading) {
                Text(transactionRowViewModel.transaction.name ?? "-")
                    .font(.body)
                    .foregroundColor((transactionRowViewModel.transaction.transactionType == FMTransaction.TransactionType.income.rawValue) ? .green : .red)
                Text(transactionRowViewModel.transactionAt())
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            .padding([.top, .bottom], 5)
            Spacer()
            Text("\(transactionRowViewModel.transaction.value ?? 0.0, specifier: "%0.2f")")
                .font(.body)
                .bold()
                .foregroundColor((transactionRowViewModel.transaction.transactionType == FMTransaction.TransactionType.income.rawValue) ? .green : .red)
            
//            if let type = transactionRowViewModel.transaction.transactionType {
//                Text("\(type)")
//                    .font(.footnote)
//                    .foregroundColor(.green)
//                    .padding([.top, .bottom], 2)
//                    .padding([.leading, .trailing], 8)
//                    .background(Color.green.opacity(0.2))
//                    .clipShape(Capsule())
//            } else if let expenseCategory = transactionRowViewModel.transaction.expenseCategory {
//                Text("\(FMTransaction.ExpenseCategory(rawValue: expenseCategory)?.rawValue.capitalized ?? "")")
//                    .font(.footnote)
//                    .foregroundColor(.red)
//                    .padding([.top, .bottom], 2)
//                    .padding([.leading, .trailing], 8)
//                    .background(Color.red.opacity(0.2))
//                    .clipShape(Capsule())
//            }
        }
        .animation(nil)
    }
    
}

//struct FMTransactionRow_Previews: PreviewProvider {
//    static var previews: some View {
//        FMTransactionRowView(transactionRowViewModel: FMTransactionRowViewModel(transaction: FMTransaction.sampleData.first!))
//    }
//}
