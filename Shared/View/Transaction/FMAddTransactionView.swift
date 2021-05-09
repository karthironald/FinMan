//
//  FMAddTransactionView.swift
//  FinMan
//
//  Created by Karthick Selvaraj on 10/04/21.
//

import SwiftUI

struct FMAddTransactionView: View {
    @State var value: String = ""
    @State var frequency: FMTransaction.Frequency = .onetime
    @State var source: FMTransaction.Source = .earned
    @State var comments: String = ""
    
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
                Section(footer: Text("\(source.info)").padding(.leading)) {
                    Picker("Frequency", selection: $frequency) {
                        ForEach(FMTransaction.Frequency.allCases, id: \.self) { freq in
                            Text("\(freq.title)")
                        }
                    }
                    .pickerStyle(DefaultPickerStyle())
                    Picker("Source", selection: $source) {
                        ForEach(FMTransaction.Source.allCases, id: \.self) { source in
                            Text("\(source.title)")
                        }
                    }
                    .pickerStyle(DefaultPickerStyle())
                }

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
            let transaction = FMTransaction(value: Double(value) ?? 0.0, frequency: frequency.rawValue, source: source.rawValue, comments: comments)
            viewModel?.addNew(transaction: transaction)
        } else {
            if let transaction = transactionRowViewModel?.transaction {
                var updatedTransaction = transaction
                updatedTransaction.value = Double(value) ?? 0.0
                updatedTransaction.frequency = frequency.rawValue
                updatedTransaction.source = source.rawValue
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
