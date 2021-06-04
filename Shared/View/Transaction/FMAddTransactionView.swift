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
    
    @Namespace private var animation
    @State var value: String = ""
    @State var frequency: FMTransaction.IncomeFrequency = .onetime
    @State var source: FMTransaction.IncomeSource = .earned
    @State var comments: String = ""
    @State var transactionType: FMTransaction.TransactionType = .income
    @State var expenseCategory: FMTransaction.ExpenseCategory = .housing
    @State var transactionDate: Date = Date()
    
    @State var shouldShowIncomeFrequency = false
    @State var shouldShowIncomeSource = false
    @State var shouldShowExpenseCategory = false
    
    @State private var alertInfoMessage = ""
    @State private var shouldShowAlert = false
    
    var viewModel: FMTransactionListViewModel? = nil
    var transactionRowViewModel: FMTransactionRowViewModel? = nil
    @Binding var shouldPresentAddTransactionView: Bool
    
    var body: some View {
        ZStack {
            VStack(spacing: 15) {
                HStack {
                    Text("Amount").foregroundColor(.secondary)
                    Spacer()
                    FMTextField(title: "Enter amount", keyboardType: .decimalPad, height: 40, value: $value, infoMessage: .constant(""))
                        .frame(width: 200, alignment: .center)
                }
                
                HStack {
                    Text("Type").foregroundColor(.secondary)
                    Spacer()
                    Picker("Type", selection: $transactionType.animation()) {
                        ForEach(FMTransaction.TransactionType.allCases, id: \.self) { transType in
                            Text("\(transType.rawValue.capitalized)")
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(width: 200, alignment: .center)
                }
                if transactionType == .income {
                    HStack {
                        Text("Frequency").foregroundColor(.secondary)
                        Spacer()
                        Button("\(frequency.rawValue.capitalized)") {
                            withAnimation {
                                shouldShowIncomeFrequency.toggle()
                            }
                        }
                        .modifier(TagStyledButton())
                        .matchedGeometryEffect(id: "incomeFreq", in: animation, properties: .position)
                    }
                    HStack {
                        Text("Source").foregroundColor(.secondary)
                        Spacer()
                        Button("\(source.rawValue.capitalized)") {
                            withAnimation {
                                shouldShowIncomeSource.toggle()
                            }
                        }
                        .modifier(TagStyledButton())
                        .matchedGeometryEffect(id: "incomeSource", in: animation, properties: .position)
                    }
                } else {
                    HStack {
                        Text("Category").foregroundColor(.secondary)
                        Spacer()
                        Button("\(expenseCategory.rawValue.capitalized)") {
                            withAnimation(Animation.spring()) {
                                shouldShowExpenseCategory.toggle()
                            }
                        }
                        .modifier(TagStyledButton())
                        .matchedGeometryEffect(id: "expenseCategory", in: animation, properties: .position)
                    }
                }
                FMButton(title: "Save", type: .primary) {
                    saveButtonTapped()
                }
                .disabled(Double(value) ?? 0.0 <= 0.0)
                .padding(.top)
            }
            .overlay((shouldShowIncomeFrequency || shouldShowIncomeSource || shouldShowExpenseCategory) ? Color.white : nil)
            if shouldShowIncomeFrequency {
                FMGridView<FMTransaction.IncomeFrequency>(items: FMTransaction.IncomeFrequency.allCases, selectedItem: $frequency, shouldDismiss: $shouldShowIncomeFrequency)
                    .matchedGeometryEffect(id: "incomeFreq", in: animation, properties: .position)
            } else if shouldShowIncomeSource {
                FMGridView<FMTransaction.IncomeSource>(items: FMTransaction.IncomeSource.allCases, selectedItem: $source, shouldDismiss: $shouldShowIncomeSource)
                    .matchedGeometryEffect(id: "incomeSource", in: animation, properties: .position)
            } else if shouldShowExpenseCategory {
                FMGridView<FMTransaction.ExpenseCategory>(items: FMTransaction.ExpenseCategory.allCases, selectedItem: $expenseCategory, shouldDismiss: $shouldShowExpenseCategory)
                    .matchedGeometryEffect(id: "expenseCategory", in: animation, properties: .position)
            }
        }
        .padding()
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
            
            FMLoadingHelper.shared.shouldShowLoading.toggle()
            viewModel?.addNew(transaction: transaction, resultBlock: { error in
                FMLoadingHelper.shared.shouldShowLoading.toggle()
                if let error = error {
                    alertInfoMessage = error.localizedDescription
                    shouldShowAlert.toggle()
                } else {
                    shouldPresentAddTransactionView.toggle()
                }
            })
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
                
                FMLoadingHelper.shared.shouldShowLoading.toggle()
                transactionRowViewModel?.update(transaction: updatedTransaction, resultBlock: { error in
                    FMLoadingHelper.shared.shouldShowLoading.toggle()
                    if let error = error {
                        alertInfoMessage = error.localizedDescription
                        shouldShowAlert.toggle()
                    } else {
                        shouldPresentAddTransactionView.toggle()
                    }
                })
            }
        }
    }
}

struct FMAddTransactionView_Previews: PreviewProvider {
    static var previews: some View {
        FMAddTransactionView(viewModel: FMTransactionListViewModel(), shouldPresentAddTransactionView: .constant(false))
    }
}

struct TagStyledButton: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(height: 30)
            .padding(.horizontal)
            .background(AppSettings.appPrimaryColour.opacity(0.2))
            .foregroundColor(AppSettings.appPrimaryColour)
            .clipShape(Capsule())
    }
}
