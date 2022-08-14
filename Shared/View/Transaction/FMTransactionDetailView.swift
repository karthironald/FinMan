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
    
    var dateFormatter: Formatter {
        let df = DateFormatter()
        df.dateStyle = .full
        return df
    }
    
    
    // MARK: - View Body
    
    var body: some View {
        List {
            VStack(alignment: .leading) {
                Text("Value")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                Text("\(transactionRowViewModel.transaction.value, specifier: "%0.02f")")
            }
            VStack(alignment: .leading) {
                Text("Transaction Date")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                Text("\(transactionRowViewModel.transaction.transac?.dateValue() ?? Date(), formatter: dateFormatter) \(transactionRowViewModel.transaction.transactionDate?.dateValue() ?? Date(), style: .time)")
            }
            if transactionRowViewModel.transaction.transactionType == FMTransaction.TransactionType.income.rawValue {
                VStack(alignment: .leading) {
                    Text("Frequency")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    if let frequency = transactionRowViewModel.transaction.frequency {
                        Text(FMTransaction.IncomeFrequency(rawValue: frequency)?.title ?? "")
                    }
                }
                VStack(alignment: .leading) {
                    Text("Source")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    if let source = transactionRowViewModel.transaction.source {
                        Text(FMTransaction.IncomeSource(rawValue: source)?.title ?? "")
                    }
                }
            } else {
                VStack(alignment: .leading) {
                    Text("Category")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    if let category = transactionRowViewModel.transaction.expenseCategory {
                        Text(category.capitalized)
                    }
                }
            }
            VStack(alignment: .leading) {
                Text("Additional Comments")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                if let comments = transactionRowViewModel.transaction.comments, !comments.isEmpty {
                    Text(comments)
                } else {
                    Text("-")
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitle("Transaction Details", displayMode: .inline)
        .navigationBarItems(trailing: Button(action: {
            shouldPresentEditScreen.toggle()
        }, label: {
            Image(systemName: "pencil.circle")
                .resizable()
                .font(.title2)
        }))
//        .popup(isPresented: $shouldPresentEditScreen, overlayView: {
//            BottomPopupView(title: "Edit Transaction", shouldDismiss: $shouldPresentEditScreen) {
//                FMAddTransactionView(value: String(transactionRowViewModel.transaction.value), frequency: FMTransaction.IncomeFrequency(rawValue: transactionRowViewModel.transaction.frequency ?? "") ?? .onetime, source: FMTransaction.IncomeSource(rawValue: transactionRowViewModel.transaction.source ?? "") ?? .earned, comments: transactionRowViewModel.transaction.comments ?? " ", transactionType: FMTransaction.TransactionType(rawValue: transactionRowViewModel.transaction.transactionType ) ?? .income, expenseCategory: FMTransaction.ExpenseCategory(rawValue: transactionRowViewModel.transaction.expenseCategory ?? "") ?? .housing, transactionDate: transactionRowViewModel.transaction.transactionDate?.dateValue() ?? Date(), transactionRowViewModel: transactionRowViewModel, shouldPresentAddTransactionView: $shouldPresentEditScreen)
//                    .accentColor(AppSettings.appPrimaryColour)
//            }
//        })
    }
    
}

struct FMTransactionDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FMTransactionDetailView(transactionRowViewModel: FMTransactionRowViewModel(transaction: FMTransaction.sampleData.first!))
        }
    }
}
