//
//  FMAddTransactionView.swift
//  FinMan
//
//  Created by Karthick Selvaraj on 10/04/21.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct FMAddTransactionView: View {
    @State var value: String = ""
    @State var frequency: FMTransaction.IncomeFrequency = .onetime
    @State var source: FMTransaction.IncomeSource = .earned
    @State var comments: String = ""
    @State var transactionType: FMTransaction.TransactionType = .income
    @State var expenseCategory: FMTransaction.ExpenseCategory = .housing
    @State var transactionDate: Date = Date()
    
    var viewModel: FMTransactionListViewModel? = nil
    var transactionRowViewModel: FMTransactionRowViewModel? = nil
    @Binding var shouldPresentAddTransactionView: Bool
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Enter amount value", text: $value)
                        .keyboardType(.decimalPad)
                }
                Section {
                    Picker("Type", selection: $transactionType) {
                        ForEach(FMTransaction.TransactionType.allCases, id: \.self) { transType in
                            Text("\(transType.rawValue.capitalized)")
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    if transactionType == .income {
                        Picker("Frequency", selection: $frequency) {
                            ForEach(FMTransaction.IncomeFrequency.allCases, id: \.self) { freq in
                                Text("\(freq.title)")
                            }
                        }
                        .pickerStyle(DefaultPickerStyle())
                        Picker("Source", selection: $source) {
                            ForEach(FMTransaction.IncomeSource.allCases, id: \.self) { source in
                                Text("\(source.title)")
                            }
                        }
                        .pickerStyle(DefaultPickerStyle())
                    } else {
                        Picker("Category", selection: $expenseCategory) {
                            ForEach(FMTransaction.ExpenseCategory.allCases, id: \.self) { expCategory in
                                Text("\(expCategory.rawValue.capitalized)")
                            }
                        }
                        .pickerStyle(DefaultPickerStyle())
                    }
                }
                
                DatePicker("Date", selection: $transactionDate)
                
                Section {
                    ZStack(alignment: .topLeading) {
                        if comments.isEmpty {
                            Text("Enter additional comments(if any)")
                                .foregroundColor(.secondary)
                                .opacity(0.5)
                                .padding([.top, .leading], 5)
                        }
                        TextEditor(text: $comments)
                            .frame(height: 100, alignment: .center)
                    }
                }
            }
            .navigationBarTitle(Text("Add Transaction"), displayMode: .inline)
            .navigationBarItems(trailing:
                                    Button("Save") {
                                        saveButtonTapped()
                                        shouldPresentAddTransactionView.toggle()
                                    }
            )
        }
    }
    
    private func saveButtonTapped() {
        if transactionRowViewModel?.id == nil && viewModel != nil {
            var transaction = FMTransaction(value: Double(value) ?? 0.0)
            if transactionType == .income {
                transaction.frequency = frequency.rawValue
                transaction.source = source.rawValue
            } else {
                transaction.expenseCategory = expenseCategory.rawValue
            }
            transaction.transactionType = transactionType.rawValue
            transaction.comments = comments
            transaction.transactionDate = Timestamp(date: transactionDate)
            viewModel?.addNew(transaction: transaction)
        } else {
            if let transaction = transactionRowViewModel?.transaction {
                var updatedTransaction = transaction
                updatedTransaction.value = Double(value) ?? 0.0
                if transactionType == .income {
                    updatedTransaction.frequency = frequency.rawValue
                    updatedTransaction.source = source.rawValue
                } else {
                    updatedTransaction.expenseCategory = expenseCategory.rawValue
                }
                updatedTransaction.transactionType = transactionType.rawValue
                updatedTransaction.transactionDate = Timestamp(date: transactionDate)
                updatedTransaction.comments = comments
                transactionRowViewModel?.update(transaction: updatedTransaction)
            }
        }
    }
}

struct FMAddTransactionView_Previews: PreviewProvider {
    static var previews: some View {
        FMAddTransactionView(viewModel: FMTransactionListViewModel(), shouldPresentAddTransactionView: .constant(false))
    }
}
