//
//  FMTransactionRow.swift
//  FinMan (iOS)
//
//  Created by Karthick Selvaraj on 09/04/21.
//

import SwiftUI

struct FMTransactionRow: View {
    
    @ObservedObject var transactionRowViewModel: FMTransactionRowViewModel
    
    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: "\(transactionRowViewModel.imageName()).square.fill")
                .resizable()
                .frame(width: 30, height: 30)
                .padding(.trailing, 5)
                .foregroundColor(.secondary)
                .opacity(0.5)
            VStack(alignment: .leading, spacing: 2) {
                Text("\(transactionRowViewModel.transaction.value, specifier: "%0.2f")")
                    .font(.body)
                    .bold()
                Text("\(transactionRowViewModel.transaction.createdAt?.dateValue() ?? Date(), style: .time)")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text("\(FMTransaction.Frequency(rawValue: transactionRowViewModel.transaction.frequency)?.title ?? "")")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
    }
}

struct FMTransactionRow_Previews: PreviewProvider {
    static var previews: some View {
        FMTransactionRow(transactionRowViewModel: FMTransactionRowViewModel(transaction: FMTransaction.sampleData.first!))
    }
}
