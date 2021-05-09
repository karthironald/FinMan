//
//  FMTransactionDetailView.swift
//  FinMan
//
//  Created by Karthick Selvaraj on 18/04/21.
//

import SwiftUI

struct FMTransactionDetailView: View {
    
    @ObservedObject var transactionRowViewModel: FMTransactionRowViewModel
    @State var shouldPresentEditScreen = false
    
    var body: some View {
        List {
            HStack {
                Text("Value")
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(transactionRowViewModel.transaction.value, specifier: "%0.02f")")
            }
            HStack {
                Text("Frequency")
                    .foregroundColor(.secondary)
                Spacer()
                Text(FMTransaction.Frequency(rawValue: transactionRowViewModel.transaction.frequency)?.title ?? "")
            }
            HStack {
                Text("Source")
                    .foregroundColor(.secondary)
                Spacer()
                Text(FMTransaction.Source(rawValue: transactionRowViewModel.transaction.source)?.title ?? "")
            }
            HStack {
                Text("Additional Comments")
                    .foregroundColor(.secondary)
                Spacer()
                Text(transactionRowViewModel.transaction.comments ?? "-")
            }
        }
        .navigationBarTitle("Transaction Details", displayMode: .inline)
        .navigationBarItems(trailing: Button(action: {
            shouldPresentEditScreen.toggle()
        }, label: {
            Image(systemName: "pencil.circle")
                .resizable()
                .font(.title)
        }))
        .sheet(isPresented: $shouldPresentEditScreen) {
            FMAddTransactionView(value: String(transactionRowViewModel.transaction.value), frequency: FMTransaction.Frequency(rawValue: transactionRowViewModel.transaction.frequency) ?? .onetime, source: FMTransaction.Source(rawValue: transactionRowViewModel.transaction.source) ?? .earned, comments: transactionRowViewModel.transaction.comments ?? " ", transactionRowViewModel: transactionRowViewModel, shouldPresentAddTransactionView: $shouldPresentEditScreen)
        }
    }
}

struct FMTransactionDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FMTransactionDetailView(transactionRowViewModel: FMTransactionRowViewModel(transaction: FMTransaction.sampleData.first!))
        }
    }
}
