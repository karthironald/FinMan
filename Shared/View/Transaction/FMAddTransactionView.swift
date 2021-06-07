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
    
    @EnvironmentObject private var hud: FMLoadingInfoState
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
    
    @State private var keyboardWillShow = NotificationCenter.default.publisher(for: UIApplication.keyboardDidShowNotification, object: nil)
    @State private var keyboardWillHide = NotificationCenter.default.publisher(for: UIApplication.keyboardWillHideNotification, object: nil)
    @State private var bottomPadding: CGFloat = 0
    
    var viewModel: FMTransactionListViewModel? = nil
    var transactionRowViewModel: FMTransactionRowViewModel? = nil
    @Binding var shouldPresentAddTransactionView: Bool
    
    var body: some View {
        ZStack {
            VStack(spacing: AppSettings.vStackSpacing) {
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
                HStack {
                    Text("Date").foregroundColor(.secondary)
                    Spacer()
                    DatePicker("", selection: $transactionDate)
                }
                HStack {
                    Text("Comments").foregroundColor(.secondary)
                    Spacer()
                    FMTextField(title: "Enter comments", keyboardType: .default, height: 40, value: $comments, infoMessage: .constant(""))
                        .frame(width: 200, alignment: .center)
                }
                FMButton(title: "Save", type: .primary, shouldShowLoading: hud.shouldShowLoading) {
                    saveButtonTapped()
                }
                .disabled(!shouldEnableSaveButton())
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
        .onReceive(keyboardWillShow) { _ in
            bottomPadding = 80
        }
        .onReceive(keyboardWillHide) { _ in
            bottomPadding = 20
        }
        .accentColor(AppSettings.appPrimaryColour)
        .padding(.horizontal) // We are not setting `top` padding as we have padding in the BottomPopup title's bottom.
        .padding(.bottom)
        .padding(.bottom, bottomPadding) // To make the save button visisble when keyboard is presented
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
            
            hud.startLoading()
            viewModel?.addNew(transaction: transaction, resultBlock: { error in
                hud.stopLoading()
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
                
                hud.startLoading()
                transactionRowViewModel?.update(transaction: updatedTransaction, resultBlock: { error in
                    hud.stopLoading()
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
    
    func shouldEnableSaveButton() -> Bool {
        if transactionRowViewModel?.id == nil && viewModel != nil {
            return Double(value) ?? 0.0 > 0.0
        } else {
            if let originalSource = transactionRowViewModel?.transaction.source, !originalSource.isEmpty, (source.rawValue.lowercased() != originalSource.lowercased()) {
                return true 
            }
            if let originalFreq = transactionRowViewModel?.transaction.frequency, !originalFreq.isEmpty, (frequency.rawValue.lowercased() != originalFreq.lowercased()) {
                return true
            }
            if let originalExpenseCategory = transactionRowViewModel?.transaction.expenseCategory, !originalExpenseCategory.isEmpty, (expenseCategory.rawValue.lowercased() != originalExpenseCategory.lowercased()) {
                return true
            }
            let value = Double(value) ?? 0.0
            return ((value > 0.0) && value != transactionRowViewModel?.transaction.value) || (transactionType.rawValue.lowercased() != transactionRowViewModel?.transaction.transactionType.lowercased()) || (transactionDate != transactionRowViewModel?.transaction.transactionDate?.dateValue()) || (comments.lowercased() != transactionRowViewModel?.transaction.comments?.lowercased())
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
